##! Payment security monitoring script
##! Specialized monitoring for payment processing security

module PaymentSecurity;

export {
    ## Log file for payment security events
    redef enum Log::ID += { LOG };

    ## Record type for payment security events
    type Info: record {
        ## Timestamp
        ts: time &log;
        ## Connection ID
        uid: string &log;
        ## Connection tuple
        id: conn_id &log;
        ## Payment event type
        event_type: string &log;
        ## Security level
        security_level: string &log;
        ## Event description
        description: string &log;
        ## Transaction ID if available
        transaction_id: string &log &optional;
        ## Customer IP
        customer_ip: addr &log &optional;
        ## Payment method
        payment_method: string &log &optional;
    };

    ## PCI DSS compliance monitoring
    global pci_violation: event(c: connection, violation_type: string, details: string);
}

# Initialize logging
event zeek_init()
{
    Log::create_stream(PaymentSecurity::LOG, [$columns=Info, $path="payment-security"]);
}

# Monitor payment processing endpoints
event http_request(c: connection, method: string, original_URI: string,
                  unescaped_URI: string, version: string)
{
    # Monitor checkout and payment endpoints
    if ( /\/checkout|\/payment|\/billing|\/card/i in original_URI )
    {
        local info: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "payment_endpoint_access",
            $security_level = "monitor",
            $description = fmt("Payment endpoint accessed: %s", original_URI),
            $customer_ip = c$id$orig_h
        ];
        Log::write(PaymentSecurity::LOG, info);

        # Ensure HTTPS for payment pages
        if ( c$id$resp_p != 443/tcp )
        {
            local info_insecure: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "insecure_payment",
                $security_level = "critical",
                $description = "Payment page accessed over HTTP (insecure)",
                $customer_ip = c$id$orig_h
            ];
            Log::write(PaymentSecurity::LOG, info_insecure);

            NOTICE([$note=Notice::Type("PaymentSecurity::Insecure_Payment"),
                   $msg="Payment page accessed over insecure HTTP",
                   $conn=c,
                   $sub=original_URI]);
        }
    }

    # Monitor for payment API abuse
    if ( /\/api\/payment|\/api\/checkout|\/api\/billing/i in original_URI )
    {
        local info_api: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "payment_api_access",
            $security_level = "monitor",
            $description = fmt("Payment API accessed: %s", original_URI),
            $customer_ip = c$id$orig_h
        ];
        Log::write(PaymentSecurity::LOG, info_api);
    }
}

# Monitor payment form submissions
event http_entity_data(c: connection, is_orig: bool, length: count, data: string)
{
    if ( is_orig && c$http?$uri && /\/checkout|\/payment/i in c$http$uri )
    {
        # Check for credit card numbers (PCI DSS violation if unencrypted)
        if ( /\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|3[0-9]{13}|6(?:011|5[0-9]{2})[0-9]{12})\b/ in data )
        {
            local info: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "credit_card_transmission",
                $security_level = "critical",
                $description = "Credit card number detected in payment submission",
                $customer_ip = c$id$orig_h,
                $payment_method = "credit_card"
            ];
            Log::write(PaymentSecurity::LOG, info);

            NOTICE([$note=Notice::Type("PaymentSecurity::PCI_Violation"),
                   $msg="Credit card data in payment transmission",
                   $conn=c]);
        }

        # Check for CVV codes
        if ( /cvv.*[=:].*[0-9]{3,4}|cvc.*[=:].*[0-9]{3,4}/i in data )
        {
            local info_cvv: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "cvv_transmission",
                $security_level = "critical",
                $description = "CVV/CVC code detected in payment data",
                $customer_ip = c$id$orig_h,
                $payment_method = "credit_card"
            ];
            Log::write(PaymentSecurity::LOG, info_cvv);
        }

        # Monitor for multiple payment attempts
        local info_attempt: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "payment_attempt",
            $security_level = "info",
            $description = "Payment form submission detected",
            $customer_ip = c$id$orig_h
        ];
        Log::write(PaymentSecurity::LOG, info_attempt);
    }
}

# Monitor payment response codes
event http_reply(c: connection, version: string, code: count, reason: string)
{
    if ( c$http?$uri && /\/checkout|\/payment/i in c$http$uri )
    {
        local status = "unknown";
        local security_level = "info";

        if ( code == 200 )
        {
            status = "success";
            security_level = "info";
        }
        else if ( code == 402 || code == 403 )
        {
            status = "payment_declined";
            security_level = "medium";
        }
        else if ( code >= 400 && code < 500 )
        {
            status = "client_error";
            security_level = "medium";
        }
        else if ( code >= 500 )
        {
            status = "server_error";
            security_level = "high";
        }

        local info: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "payment_response",
            $security_level = security_level,
            $description = fmt("Payment response: %d %s", code, reason),
            $customer_ip = c$id$orig_h
        ];
        Log::write(PaymentSecurity::LOG, info);

        # Alert on multiple failed payments (potential fraud)
        if ( code == 402 || code == 403 )
        {
            NOTICE([$note=Notice::Type("PaymentSecurity::Payment_Declined"),
                   $msg=fmt("Payment declined: %d %s", code, reason),
                   $conn=c]);
        }
    }
}

# Monitor for tokenization and encryption compliance
event http_header(c: connection, is_orig: bool, name: string, value: string)
{
    if ( !is_orig && c$http?$uri && /\/payment|\/checkout/i in c$http$uri )
    {
        # Check for proper security headers in payment responses
        if ( name == "STRICT-TRANSPORT-SECURITY" )
        {
            local info_hsts: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "security_header_hsts",
                $security_level = "good",
                $description = "HSTS header present in payment response",
                $customer_ip = c$id$orig_h
            ];
            Log::write(PaymentSecurity::LOG, info_hsts);
        }

        if ( name == "CONTENT-SECURITY-POLICY" )
        {
            local info_csp: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "security_header_csp",
                $security_level = "good",
                $description = "CSP header present in payment response",
                $customer_ip = c$id$orig_h
            ];
            Log::write(PaymentSecurity::LOG, info_csp);
        }
    }

    # Monitor for payment processor communications
    if ( is_orig && name == "HOST" )
    {
        if ( /stripe|paypal|square|authorize\.net|braintree/i in value )
        {
            local info_processor: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "payment_processor_comm",
                $security_level = "monitor",
                $description = fmt("Communication with payment processor: %s", value),
                $payment_method = "external_processor"
            ];
            Log::write(PaymentSecurity::LOG, info_processor);
        }
    }
}

# Monitor SSL certificate validation for payment processors
event ssl_established(c: connection)
{
    if ( c$ssl?$subject && /stripe|paypal|square|authorize\.net|braintree/i in c$ssl$subject )
    {
        local info: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "payment_ssl_established",
            $security_level = "good",
            $description = "Secure SSL connection to payment processor",
            $payment_method = "external_processor"
        ];
        Log::write(PaymentSecurity::LOG, info);
    }
}

# Monitor for payment-related file uploads
event file_new(f: fa_file)
{
    if ( f$source == "HTTP" && |f$conns| > 0 )
    {
        local c = f$conns[0];
        if ( c$http?$uri && /\/upload.*payment|\/payment.*upload/i in c$http$uri )
        {
            local info: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "payment_file_upload",
                $security_level = "medium",
                $description = "File upload in payment context",
                $customer_ip = c$id$orig_h
            ];
            Log::write(PaymentSecurity::LOG, info);
        }
    }
}
