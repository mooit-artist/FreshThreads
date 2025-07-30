##! FreshThreads specific network monitoring script
##! Custom Zeek script for e-commerce website monitoring

module FreshThreads;

export {
    ## Log file for FreshThreads specific events
    redef enum Log::ID += { LOG };

    ## Record type for FreshThreads events
    type Info: record {
        ## Timestamp
        ts: time &log;
        ## Connection ID
        uid: string &log;
        ## Connection tuple
        id: conn_id &log;
        ## Event type
        event_type: string &log;
        ## Event description
        description: string &log;
        ## Severity level
        severity: string &log;
        ## Additional details
        details: string &log &optional;
    };

    ## Event for suspicious e-commerce activity
    global suspicious_activity: event(c: connection, event_type: string, description: string);
}

# Initialize logging
event zeek_init()
{
    Log::create_stream(FreshThreads::LOG, [$columns=Info, $path="freshthreads"]);
}

# Monitor HTTP requests for suspicious patterns
event http_request(c: connection, method: string, original_URI: string,
                  unescaped_URI: string, version: string)
{
    local suspicious = F;
    local event_desc = "";
    local severity = "low";

    # Check for SQL injection attempts
    if ( /select|union|insert|delete|drop|update/i in original_URI )
    {
        suspicious = T;
        event_desc = "Potential SQL injection in URI";
        severity = "high";
    }

    # Check for XSS attempts
    if ( /<script|javascript:|onload=|onerror=/i in original_URI )
    {
        suspicious = T;
        event_desc = "Potential XSS attack in URI";
        severity = "high";
    }

    # Check for admin access attempts
    if ( /\/admin|\/dashboard|\/manager/i in original_URI )
    {
        event_desc = "Admin area access attempt";
        severity = "medium";
        suspicious = T;
    }

    # Check for sensitive file access
    if ( /\.env|\.git|package\.json|\.htaccess/i in original_URI )
    {
        suspicious = T;
        event_desc = "Sensitive file access attempt";
        severity = "high";
    }

    # Log suspicious activity
    if ( suspicious )
    {
        local info: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "http_suspicious",
            $description = event_desc,
            $severity = severity,
            $details = fmt("Method: %s, URI: %s", method, original_URI)
        ];
        Log::write(FreshThreads::LOG, info);

        # Generate notice for high severity events
        if ( severity == "high" )
        {
            NOTICE([$note=Notice::Type("FreshThreads::Suspicious_Activity"),
                   $msg=fmt("Suspicious HTTP activity: %s", event_desc),
                   $conn=c,
                   $sub=original_URI]);
        }
    }
}

# Monitor for brute force login attempts
event http_message_done(c: connection, is_orig: bool, stat: http_message_stat)
{
    if ( !is_orig && c$http?$uri && /\/auth|\/login/i in c$http$uri )
    {
        if ( c$http?$status_code && c$http$status_code == 401 )
        {
            local info: Info = [
                $ts = network_time(),
                $uid = c$uid,
                $id = c$id,
                $event_type = "auth_failure",
                $description = "Authentication failure",
                $severity = "medium",
                $details = fmt("URI: %s, Status: %d", c$http$uri, c$http$status_code)
            ];
            Log::write(FreshThreads::LOG, info);
        }
    }
}

# Monitor file uploads
event file_new(f: fa_file)
{
    if ( f$source == "HTTP" )
    {
        local info: Info = [
            $ts = network_time(),
            $uid = f$conns[0]$uid,
            $id = f$conns[0]$id,
            $event_type = "file_upload",
            $description = "File upload detected",
            $severity = "low",
            $details = fmt("Filename: %s, MIME: %s",
                          f$info?$filename ? f$info$filename : "unknown",
                          f$info?$mime_type ? f$info$mime_type : "unknown")
        ];
        Log::write(FreshThreads::LOG, info);
    }
}

# Monitor for large data transfers (potential data exfiltration)
event connection_state_remove(c: connection)
{
    if ( c$orig$size > 10485760 )  # 10MB threshold
    {
        local info: Info = [
            $ts = network_time(),
            $uid = c$uid,
            $id = c$id,
            $event_type = "large_transfer",
            $description = "Large data transfer detected",
            $severity = "medium",
            $details = fmt("Bytes transferred: %d", c$orig$size)
        ];
        Log::write(FreshThreads::LOG, info);
    }
}
