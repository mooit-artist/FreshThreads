##! E-commerce security monitoring script
##! Specialized monitoring for online retail security

module EcommerceSecurity;

export {
    ## Log file for e-commerce security events
    redef enum Log::ID += { LOG };

    ## Record type for e-commerce security events
    type Info: record {
        ## Timestamp
        ts: time &log;
        ## Connection ID
        uid: string &log;
        ## Connection tuple
        id: conn_id &log;
        ## Security event type
        event_type: string &log;
        ## Risk level
        risk_level: string &log;
        ## Event details
        details: string &log;
        ## Customer IP if applicable
        customer_ip: addr &log &optional;
        ## Affected resource
        resource: string &log &optional;
    };
}

# Initialize logging
event zeek_init()
{
    Log::create_stream(EcommerceSecurity::LOG, [$columns=Info, $path="ecommerce-security"]);
}

# Monitor shopping cart manipulation
event http_request(c: connection, method: string, original_URI: string,
                  unescaped_URI: string, version: string)
{
    # Check for price manipulation attempts
    if ( /price.*[=:].*0\.0+[^0-9]|price.*[=:].*-/i in original_URI )
    {
        local info: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "price_manipulation",
            $risk_level = "critical",
            $details = fmt("Potential price manipulation in URI: %s", original_URI),
            $customer_ip = c$id$orig_h,
            $resource = original_URI
        ];
        Log::write(EcommerceSecurity::LOG, info);

        NOTICE([$note=Notice::Type("EcommerceSecurity::Price_Manipulation"),
               $msg="Price manipulation attempt detected",
               $conn=c,
               $sub=original_URI]);
    }

    # Check for inventory manipulation
    if ( /quantity.*[=:].*[0-9]{3,}|stock.*[=:].*-/i in original_URI )
    {
        local info2: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "inventory_manipulation",
            $risk_level = "high",
            $details = fmt("Potential inventory manipulation: %s", original_URI),
            $customer_ip = c$id$orig_h,
            $resource = original_URI
        ];
        Log::write(EcommerceSecurity::LOG, info2);
    }

    # Monitor checkout process bypass attempts
    if ( /order-success|order-complete|payment-success/i in original_URI && method == "GET" )
    {
        local info3: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "checkout_bypass",
            $risk_level = "critical",
            $details = fmt("Direct access to success page: %s", original_URI),
            $customer_ip = c$id$orig_h,
            $resource = original_URI
        ];
        Log::write(EcommerceSecurity::LOG, info3);

        NOTICE([$note=Notice::Type("EcommerceSecurity::Checkout_Bypass"),
               $msg="Checkout process bypass attempt",
               $conn=c,
               $sub=original_URI]);
    }

    # Monitor for rapid product catalog access (scraping)
    if ( /\/products|\/catalog|\/items/i in original_URI )
    {
        # This would typically integrate with a rate limiting system
        local info4: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "catalog_access",
            $risk_level = "low",
            $details = fmt("Product catalog access: %s", original_URI),
            $customer_ip = c$id$orig_h,
            $resource = original_URI
        ];
        Log::write(EcommerceSecurity::LOG, info4);
    }
}

# Monitor HTTP POST requests for transaction security
event http_entity_data(c: connection, is_orig: bool, length: count, data: string)
{
    if ( is_orig && c$http?$uri )
    {
        # Check for credit card patterns in POST data
        if ( /\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13})\b/ in data )
        {
            local info: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "credit_card_data",
                $risk_level = "high",
                $details = "Credit card pattern detected in POST data",
                $customer_ip = c$id$orig_h,
                $resource = c$http$uri
            ];
            Log::write(EcommerceSecurity::LOG, info);

            NOTICE([$note=Notice::Type("EcommerceSecurity::Credit_Card_Exposure"),
                   $msg="Credit card data detected in HTTP POST",
                   $conn=c]);
        }

        # Monitor for session token manipulation
        if ( /session.*[=:].*[a-zA-Z0-9]{32,}/ in data && /admin|root|system/ in data )
        {
            local info2: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "session_manipulation",
                $risk_level = "high",
                $details = "Potential session token manipulation with elevated privileges",
                $customer_ip = c$id$orig_h,
                $resource = c$http$uri
            ];
            Log::write(EcommerceSecurity::LOG, info2);
        }
    }
}

# Monitor SSL/TLS for payment security
event ssl_established(c: connection)
{
    if ( c$id$resp_p == 443/tcp )
    {
        local info: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "ssl_connection",
            $risk_level = "info",
            $details = "SSL/TLS connection established for secure transaction",
            $customer_ip = c$id$orig_h
        ];
        Log::write(EcommerceSecurity::LOG, info);
    }
}

# Monitor for suspicious user agents
event http_header(c: connection, is_orig: bool, name: string, value: string)
{
    if ( is_orig && name == "USER-AGENT" )
    {
        # Check for bot/scraper user agents
        if ( /bot|crawler|spider|scraper|automated|python|curl|wget/i in value )
        {
            local info: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "bot_activity",
                $risk_level = "medium",
                $details = fmt("Bot/automated access detected: %s", value),
                $customer_ip = c$id$orig_h
            ];
            Log::write(EcommerceSecurity::LOG, info);
        }

        # Check for security scanning tools
        if ( /nmap|nessus|burp|zap|sqlmap|nikto|openvas/i in value )
        {
            local info2: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "security_scan",
                $risk_level = "critical",
                $details = fmt("Security scanning tool detected: %s", value),
                $customer_ip = c$id$orig_h
            ];
            Log::write(EcommerceSecurity::LOG, info2);

            NOTICE([$note=Notice::Type("EcommerceSecurity::Security_Scan"),
                   $msg="Security scanning tool detected",
                   $conn=c,
                   $sub=value]);
        }
    }
}
