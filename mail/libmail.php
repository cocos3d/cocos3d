<?php
class Mail
{
    private $charset = "UTF-8";
    private $boundary = "";
    private $SubBody = array();
    private $body = array();
    private $ctencoding = "base64";
    private $count_body = 1;
    private $checkAddress = true;
    private $headers = array();
    private $ready_headers = array();
    private $names_email = array();
    private $receipt = 0;
    private $smtpsendto = array();
    private $sendto = array();
    private $acc = array();
    private $abcc = array();
    private $smtp = array();
    private $smtp_log = '';
    private $log_on = false;
    private $body_header = array();
    public $status_mail = array('status' => true, "message" => 'ок');
    public function __construct($charset = "", $ctencoding = '')
    {
        $this->boundary = md5(uniqid("myboundary"));
        $this->smtp['on'] = false;
        if (strlen($ctencoding) and $ctencoding == '8bit')
        {
            $this->ctencoding = '8bit';
        }
        if (strlen($charset))
        {
            $this->charset = strtolower($charset);
            if ($this->charset == "us-ascii")
            {
                $this->ctencoding = "7bit";
            }
        }
    }
    public function Body($text, $text_html = "", $alternative_text = '', $resource = 'webi')
    {
        if (!strlen($resource))
            $resource = 'webi';
        if ($text_html == "html")
            $text_html = "text/html";
        else
            $text_html = "text/plain";
        if ($this->ctencoding == 'base64')
        {
            if (strlen($alternative_text))
                $alternative_text = chunk_split(base64_encode($alternative_text));
            if (strlen($text))
                $text = chunk_split(base64_encode($text));
        }
        if (!strlen($alternative_text))
        {
            $body = "Content-Type: ".$text_html."; charset=".$this->charset."\r\n";
            $body.="Content-Transfer-Encoding: ".$this->ctencoding."\r\n\r\n";
            $body.=$text;
        }
        elseif (strlen($alternative_text) and $text_html == 'text/html')
        {
            $body = "Content-Type: multipart/alternative; boundary=ALT-".$this->boundary."\r\n\r\n";
            $body.="--ALT-".$this->boundary."\r\n";
            $body.="Content-Type: text/plain; charset=".$this->charset."\r\n";
            $body.="Content-Transfer-Encoding: ".$this->ctencoding."\r\n\r\n";
            $body.=$alternative_text."\r\n";
            $body.="--ALT-".$this->boundary."\r\n";
            $body.="Content-Type: text/html; charset=".$this->charset."\r\n";
            $body.="Content-Transfer-Encoding: ".$this->ctencoding."\r\n\r\n";
            $body.=$text."\r\n";
            $body.="--ALT-".$this->boundary."--";
        }
        $this->SubBody[$resource]['body'][0] = $body;
    }
    protected function mime_content_type($file)
    {
        $ext = strtolower(substr(strrchr(basename($file), '.'), 1));
        switch ($ext)
        {
            case 'jpg': return 'image/jpeg';
            case 'jpeg': return 'image/jpeg';
            case 'gif': return 'image/gif';
            case 'png': return 'image/png';
            case 'ico': return 'image/x-icon';
            case 'txt': return 'text/plain';

            default: return 'application/octet-stream';
        }
    }

    public function Attach($filename, $new_name_filename = "", $filetype = "", $disposition = "", $resource = 'webi')
    {
        if (!strlen($resource))
            $resource = 'webi';
        if (!file_exists($filename))
        {
            return FALSE;
        }
        if (strlen($new_name_filename))
            $basename = basename($new_name_filename);
        else
            $basename = basename($filename);

        $charset_name = "=?".$this->charset."?B?".base64_encode($basename)."?=";
        if (!strlen($filetype))
            $filetype = $this->mime_content_type($basename);
        $body = "Content-Type: ".$filetype."; name=\"$charset_name\"\r\n";
        $body.="Content-Transfer-Encoding: base64\r\n";
        if ($disposition == 'attachment')
        {
            $body.="Content-Disposition: attachment; filename=\"$charset_name\"\r\n";
        }
        $body.="Content-ID: <".$basename.">\r\n";
        $body.="\r\n";
        $body.=chunk_split(base64_encode(file_get_contents($filename)));
        if ($disposition == 'attachment')
            $this->SubBody[$resource]['mixed'][] = $body;
        else
        {
            $this->SubBody[$resource]['body'][$this->count_body] = $body;
            $this->count_body++;
        }
    }
    public function BuildMail($resource = 'webi')
    {
        if (!strlen($resource))
            $resource = 'webi';
        $this->ready_headers[$resource] = '';        
        if (isset($this->SubBody[$resource]['body']))
            $resource_body = $resource;
        else
            $resource_body = 'webi';
        if (!is_array($this->sendto[$resource]) OR !count($this->sendto[$resource]))
        {
            $this->status_mail['status'] = false;
            $this->status_mail['message'] = "Error : no recipient selected for ".$resource;
            // return false;
        }
        if (!isset($this->body[$resource_body]))
        {
            if (count($this->SubBody[$resource_body]['body']) > 1)
            {
                $body = implode("\r\n--REL-".$this->boundary."\r\n", $this->SubBody[$resource_body]['body']);
                $body = "Content-Type: multipart/related; boundary=REL-".$this->boundary."\r\n\r\n"
                        .'--REL-'.$this->boundary."\r\n".$body.'--REL-'.$this->boundary."--";
            }
            else
            {
                $body = $this->SubBody[$resource_body]['body'][0];
            }
            if (isset($this->SubBody[$resource_body]['mixed']) AND count($this->SubBody[$resource_body]['mixed']))
            {
                $bodymix = implode('--MIX-'.$this->boundary."\r\n", $this->SubBody[$resource_body]['mixed']);
                $body = $body."\r\n--MIX-".$this->boundary."\r\n".$bodymix;
                $body = "Content-Type: multipart/mixed; boundary=MIX-".$this->boundary."\r\n\r\n"
                        .'--MIX-'.$this->boundary."\r\n".$body.'--MIX-'.$this->boundary."--";
            }
            unset($this->SubBody[$resource_body]);
            $temp_mass = explode("\r\n\r\n", $body);
            $this->body_header[$resource_body] = $temp_mass[0];
            unset($temp_mass[0]);
            $this->body[$resource_body] = implode("\r\n\r\n", $temp_mass);
            unset($temp_mass);
            unset($body);
        }
        $temp_mass = array();
        foreach ($this->sendto[$resource] as $key => $value)
        {

            if (strlen($this->names_email[$resource]['To'][$value]))
                $temp_mass[] = "=?".$this->charset."?Q?".str_replace("+", "_", str_replace("%", "=", urlencode(strtr($this->names_email[$resource]['To'][$value], "\r\n", "  "))))."?= <".$value.">";
            else
                $temp_mass[] = $value;
        }
        $this->headers[$resource]['To'] = implode(", ", $temp_mass);
        if (isset($this->acc[$resource]) and count($this->acc[$resource]) > 0)
            $this->headers[$resource]['CC'] = implode(", ", $this->acc[$resource]);
        if (isset($this->abcc[$resource]) and count($this->abcc[$resource]) > 0)
            $this->headers[$resource]['BCC'] = implode(", ", $this->abcc[$resource]);
        if ($this->receipt)
        {
            if (isset($this->headers["Reply-To"]))
                $this->headers["Disposition-Notification-To"] = $this->headers["Reply-To"];
            else
                $this->headers["Disposition-Notification-To"] = $this->headers['From'];
        }
        if ($this->charset != "")
        {
            $this->headers["Mime-Version"] = "1.0";
        }
        $this->headers["X-Mailer"] = "Php_libMail_v_2.0(webi.ru)";
        if (!isset($this->headers[$resource]['Subject']) and isset($this->headers['webi']['Subject']))
            $this->headers[$resource]['Subject'] = $this->headers['webi']['Subject'];
        if ($this->smtp['on'])
        {
            $user_domen = explode('@', $this->headers['From']);
            $this->ready_headers[$resource] .= "Date: ".date("r")."\r\n";
            $this->ready_headers[$resource] .= "Message-ID: <".rand().".".$resource.date("YmjHis")."@".$user_domen[1].">\r\n";
            foreach ($this->headers[$resource] as $key => $value)
            {
                $new_mass_head[$key] = $value;
            }            
            foreach ($this->headers as $key => $value)
            {
                if (!is_array($value))
                    $new_mass_head[$key] = $value;
            }
            reset($new_mass_head);
            while (list( $hdr, $value ) = each($new_mass_head))
            {
                if ($hdr == "From" and strlen($this->names_email['from']))
                    $this->ready_headers[$resource] .= $hdr.": =?".$this->charset."?Q?".str_replace("+", "_", str_replace("%", "=", urlencode(strtr($this->names_email['from'], "\r\n", "  "))))."?= <".$value.">\r\n";
                elseif ($hdr == "Reply-To" and strlen($this->names_email['Reply-To']))
                    $this->ready_headers[$resource] .= $hdr.": =?".$this->charset."?Q?".str_replace("+", "_", str_replace("%", "=", urlencode(strtr($this->names_email['Reply-To'], "\r\n", "  "))))."?= <".$value.">\r\n";
                elseif ($hdr != "BCC")
                    $this->ready_headers[$resource] .= $hdr.": ".$value."\r\n";
            }
        }
        else
        {
            foreach ($this->headers[$resource] as $key => $value)
            {
                $new_mass_head[$key] = $value;
            }
            foreach ($this->headers as $key => $value)
            {
                if (!is_array($value))
                    $new_mass_head[$key] = $value;
            }
            reset($new_mass_head);
            while (list( $hdr, $value ) = each($new_mass_head))
            {
                if ($hdr == "From" and strlen($this->names_email['from']))
                    $this->ready_headers[$resource] .= $hdr.": =?".$this->charset."?Q?".str_replace("+", "_", str_replace("%", "=", urlencode(strtr($this->names_email['from'], "\r\n", "  "))))."?= <".$value.">\r\n";
                elseif ($hdr == "Reply-To" and strlen($this->names_email['Reply-To']))
                    $this->ready_headers[$resource] .= $hdr.": =?".$this->charset."?Q?".str_replace("+", "_", str_replace("%", "=", urlencode(strtr($this->names_email['Reply-To'], "\r\n", "  "))))."?= <".$value.">\r\n";
                elseif ($hdr != "Subject" and $hdr != "To")
                    $this->ready_headers[$resource] .= "$hdr: $value\r\n";
            }
        }
        $this->ready_headers[$resource].=$this->body_header[$resource_body]."\r\n";
    }
    public function autoCheck($bool)
    {
        if ($bool)
            $this->checkAddress = true;
        else
            $this->checkAddress = false;
    }
    public function log_on($bool)
    {
        if ($bool)
            $this->log_on = true;
        else
            $this->log_on = false;
    }
    public function Subject($subject, $resource = 'webi')
    {
        if (!strlen($resource))
            $resource = 'webi';
        $this->headers[$resource]['Subject'] = "=?".$this->charset."?Q?".str_replace("+", "_", str_replace("%", "=", urlencode(strtr($subject, "\r\n", "  "))))."?=";
    }
    public function From($from)
    {
        if (!is_string($from))
        {
            $this->status_mail['status'] = false;
            $this->status_mail['message'] = "Error, From should be inline";
            return FALSE;
        }
        $temp_mass = explode(';', $from);
        if (count($temp_mass) == 2)
        {
            $this->names_email['from'] = $temp_mass[0];
            $this->headers['From'] = $temp_mass[1];
        }
        else
        {
            $this->names_email['from'] = '';
            $this->headers['From'] = $from;
        }
    }
    public function ReplyTo($address)
    {
        if (!is_string($address))
            return false;
        $temp_mass = explode(';', $address);
        if (count($temp_mass) == 2)
        {
            $this->names_email['Reply-To'] = $temp_mass[0];
            $this->headers['Reply-To'] = $temp_mass[1];
        }
        else
        {
            $this->names_email['Reply-To'] = '';
            $this->headers['Reply-To'] = $address;
        }
    }
    public function Receipt()
    {
        $this->receipt = 1;
    }
    public function To($to, $resource = 'webi')
    {
        if (!strlen($resource))
            $resource = 'webi';
        if (is_array($to))
        {
            foreach ($to as $key => $value)
            {
                $temp_mass = explode(';', $value);
                if (count($temp_mass) == 2)
                {
                    $this->smtpsendto[$resource][$temp_mass[1]] = $temp_mass[1];
                    $this->names_email[$resource]['To'][$temp_mass[1]] = $temp_mass[0];
                    $this->sendto[$resource][] = $temp_mass[1];
                }
                else
                {
                    $this->smtpsendto[$resource][$value] = $value;
                    $this->names_email[$resource]['To'][$value] = '';
                    $this->sendto[$resource][] = $value;
                }
            }
        }
        else
        {
            $temp_mass = explode(';', $to);
            if (count($temp_mass) == 2)
            {
                $this->sendto[$resource][] = $temp_mass[1];
                $this->smtpsendto[$resource][$temp_mass[1]] = $temp_mass[1];
                $this->names_email[$resource]['To'][$temp_mass[1]] = $temp_mass[0];
            }
            else
            {
                $this->sendto[$resource][] = $to;
                $this->smtpsendto[$resource][$to] = $to;

                $this->names_email[$resource]['To'][$to] = '';
            }
        }
        if ($this->checkAddress == true)
            $this->CheckAdresses($this->sendto[$resource]);
    }
    private function CheckAdresses($aad)
    {
        foreach ($aad as $key => $value)
        {
            if (!$this->ValidEmail($value))
            {
                $this->status_mail['status'] = false;
                $this->status_mail['message'] = "Error : wrong email ".$value;
                return FALSE;
            }
        }
    }
    public function ValidEmail($address)
    {
        if (function_exists('filter_list'))
        {
            $valid_email = filter_var($address, FILTER_VALIDATE_EMAIL);
            if ($valid_email !== false)
                return true;
            else
                return false;
        }
        else
        {
            if (ereg(".*<(.+)>", $address, $regs))
            {
                $address = $regs[1];
            }
            if (ereg("^[^@  ]+@([a-zA-Z0-9\-]+\.)+([a-zA-Z0-9\-]{2}|net|com|gov|mil|org|edu|int)\$", $address))
                return true;
            else
                return false;
        }
    }
    public function Cc($cc, $resource = 'webi')
    {
        if (!strlen($resource))
            $resource = 'webi';

        if (is_array($cc))
        {
            foreach ($cc as $key => $value)
            {
                $this->smtpsendto[$resource][$value] = $value;
                $this->acc[$resource][$value] = $value;
            }
        }
        else
        {
            $this->acc[$resource][$cc] = $cc;
            $this->smtpsendto[$resource][$cc] = $cc;
        }
        if ($this->checkAddress == true)
            $this->CheckAdresses($this->acc[$resource]);
    }
    public function Bcc($bcc, $resource = 'webi')
    {
        if (!strlen($resource))
            $resource = 'webi';
        if (is_array($bcc))
        {
            foreach ($bcc as $key => $value)
            {
                $this->smtpsendto[$resource][$value] = $value;
                $this->abcc[$resource][$value] = $value;
            }
        }
        else
        {
            $this->abcc[$resource][$bcc] = $bcc;
            $this->smtpsendto[$resource][$bcc] = $bcc;
        }
        if ($this->checkAddress == true)
            $this->CheckAdresses($this->abcc[$resource]);
    }
    public function Organization($org)
    {
        if (trim($org != ""))
            $this->headers['Organization'] = $org;
    }
    public function Priority($priority)
    {
        $priorities = array('1 (Highest)', '2 (High)', '3 (Normal)', '4 (Low)', '5 (Lowest)');
        if (!intval($priority))
            return false;

        if (!isset($priorities[$priority - 1]))
            return false;

        $this->headers["X-Priority"] = $priorities[$priority - 1];

        return true;
    }
    public function smtp_on($smtp_serv, $login, $pass, $port = 25, $timeout = 5)
    {
        $this->smtp['on'] = true; // smtp transfer on
        $this->smtp['serv'] = $smtp_serv;
        $this->smtp['login'] = $login;
        $this->smtp['pass'] = $pass;
        $this->smtp['port'] = $port;
        $this->smtp['timeout'] = $timeout;
    }
    private function get_data($smtp_conn)
    {
        $data = "";
        while ($str = fgets($smtp_conn, 515))
        {
            $data .= $str;
            if (substr($str, 3, 1) == " ")
            {
                break;
            }
        }
        return $data;
    }
    private function add_log($text)
    {
        if ($this->log_on)
            $this->smtp_log.=$text;
    }
    public function Send()
    {
        if (!$this->status_mail['status'])
        {
            return FALSE;
        }
        if (!$this->smtp['on'])
        {
            foreach ($this->sendto as $key => $value)
            {
                $strTo = implode(", ", $this->sendto[$key]);
                $this->BuildMail($key);
                if (!$this->status_mail['status'])
                {
                    return FALSE;
                }
                if (isset($this->body[$key]))
                    $body_resource = $key;
                else
                    $body_resource = 'webi';
                $res = @mail($strTo, $this->headers[$key]['Subject'], $this->body[$body_resource], $this->ready_headers[$key]);
                if (!$res)
                {
                    $this->status_mail['status'] = false;
                    $this->status_mail['message'] = "Error : mail() function returns error";
                }
                elseif ($this->status_mail['status'])
                {
                    $this->add_log('TO: '.$strTo."\n");
                    $this->add_log("Subject: ".$this->headers[$key]['Subject']."\n");
                    $this->add_log($this->ready_headers[$key]."\n\n");
                    $this->add_log($this->body[$body_resource]."\n\n\n");
                    $this->status_mail['status'] = true;
                    $this->status_mail['message'] = "Message successfully sent by mail()";
                }
                if ($key != 'webi')
                {
                    unset($this->headers[$key]);
                    unset($this->ready_headers[$key]);
                }
                if ($body_resource != 'webi')
                {
                    unset($this->body[$body_resource]);
                }
            }
            if ($this->status_mail['status'])
            {
                return true;
            }
            else
            {
                return FALSE;
            }
        }
        else
        {
            if (!$this->smtp['serv'] OR !$this->smtp['login'] OR !$this->smtp['pass'] OR !$this->smtp['port'])
            {
                $this->status_mail['status'] = false;
                $this->status_mail['message'] = "Error : missing required SMTP values ";
                return false;
            }
            $user_domen = explode('@', $this->headers['From']);
            $smtp_conn = fsockopen($this->smtp['serv'], $this->smtp['port'], $errno, $errstr, $this->smtp['timeout']);
            if (!$smtp_conn)
            {
                $this->add_log("can't connect to server\n\n");
                fclose($smtp_conn);
                $this->status_mail['status'] = false;
                $this->status_mail['message'] = "Error: can't connect to server";
                return false;
            }
            $data = $this->get_data($smtp_conn)."\n";
            $this->add_log($data);
            fputs($smtp_conn, "EHLO ".$user_domen[0]."\r\n");
            $this->add_log("I: EHLO ".$user_domen[0]."\n");
            $data = $this->get_data($smtp_conn)."\n";
            $this->add_log($data);
            $code = substr($data, 0, 3);
            if ($code != 250)
            {
                $this->add_log("Error greeting EHLO \n");
                fclose($smtp_conn);
                $this->status_mail['status'] = false;
                $this->status_mail['message'] = "Error: greeting EHLO";
                return false;
            }
            fputs($smtp_conn, "AUTH LOGIN\r\n");
            $this->add_log( "I: AUTH LOGIN\n");
            $data = $this->get_data($smtp_conn)."\n";
            $this->add_log($data);
            $code = substr($data, 0, 3);
            if ($code != 334)
            {
                $this->add_log("server denies authorization \n");
                fclose($smtp_conn);
                $this->status_mail['status'] = false;
                $this->status_mail['message'] = "server denies authorization";
                return false;
            }
            fputs($smtp_conn, base64_encode($this->smtp['login'])."\r\n");
            $this->add_log( "I: ".base64_encode($this->smtp['login'])."\n");
            $data = $this->get_data($smtp_conn)."\n";
            $this->add_log($data);
            $code = substr($data, 0, 3);
            if ($code != 334)
            {
                $this->add_log( "user access failed\n");
                fclose($smtp_conn);
                $this->status_mail['status'] = false;
                $this->status_mail['message'] = "user SMTP access failed ";
                return false;
            }
            fputs($smtp_conn, base64_encode($this->smtp['pass'])."\r\n");
            $this->add_log("I: parol_skryt\n");
            $data = $this->get_data($smtp_conn)."\n";
            $this->add_log($data);
            $code = substr($data, 0, 3);
            if ($code != 235)
            {
                $this->add_log("wrong password\n");
                fclose($smtp_conn);
                $this->status_mail['status'] = false;
                $this->status_mail['message'] = "wrong password for SMTP";
                return false;
            }
            foreach ($this->smtpsendto as $key_res => $value_res)
            {
                $this->BuildMail($key_res);
                if (!$this->status_mail['status'])
                {
                    return FALSE;
                }
                if (isset($this->body[$key_res]))
                    $body_resource = $key_res;
                else
                    $body_resource = 'webi';
                fputs($smtp_conn, "MAIL FROM:<".$this->headers['From']."> SIZE=".strlen($this->ready_headers[$key_res]."\r\n".$this->body[$body_resource])."\r\n");
                $this->add_log("I: MAIL FROM:<".$this->headers['From']."> SIZE=".strlen($this->ready_headers[$key_res]."\r\n".$this->body[$body_resource])."\n");
                $data = $this->get_data($smtp_conn)."\n";
                $this->add_log($data); 
                $code = substr($data, 0, 3);
                if ($code != 250)
                {
                    $this->add_log("command MAIL FROM denied by server\n");
                    fclose($smtp_conn);
                    $this->status_mail['status'] = false;
                    $this->status_mail['message'] = "command MAIL FROM through SMTP denied by server ";
                    return false;
                }
                foreach ($this->smtpsendto[$key_res] as $keywebi => $valuewebi)
                {
                    fputs($smtp_conn, "RCPT TO:<".$valuewebi.">\r\n");
                    $this->add_log("I: RCPT TO:<".$valuewebi.">\n");
                    $data = $this->get_data($smtp_conn)."\n";
                    $this->add_log($data);
                    $code = substr($data, 0, 3);
                    if ($code != 250 AND $code != 251)
                    {
                        $this->add_log( "Server denied RCPT TO command\n");
                        fclose($smtp_conn);
                        $this->status_mail['status'] = false;
                        $this->status_mail['message'] = "Server denied RCPT TO command through SMTP";
                        return false;
                    }
                }
                fputs($smtp_conn, "DATA\r\n");
                $this->add_log("I: DATA\n");
                $data = $this->get_data($smtp_conn)."\n";
                $this->add_log($data);                
                $code = substr($data, 0, 3);
                if ($code != 354)
                {
                    $this->add_log( "server denied DATA command \n");
                    fclose($smtp_conn);
                    $this->status_mail['status'] = false;
                    $this->status_mail['message'] = "server denied DATA command through SMTP";
                    return false;
                }
                fputs($smtp_conn, $this->ready_headers[$key_res]."\r\n".$this->body[$body_resource]."\r\n.\r\n");
                $this->add_log("I: ".$this->ready_headers[$key_res]."\r\n".$this->body[$body_resource]."\r\n.\r\n");
                $data = $this->get_data($smtp_conn)."\n";
                $this->add_log($data);
                $code = substr($data, 0, 3);
                if ($code != 250)
                {
                    $this->add_log("error sending message\n");
                    fclose($smtp_conn);
                    $this->status_mail['status'] = false;
                    $this->status_mail['message'] = "error sending message through SMTP";
                    return false;
                }
                fputs($smtp_conn, "RSET\r\n");
                $this->add_log("I: RSET\n");
                $data = $this->get_data($smtp_conn)."\n";
                $this->add_log($data);
                $code = substr($data, 0, 3);
                if ($code != 250)
                {
                    $this->add_log("error sending message\n");
                    fclose($smtp_conn);
                    $this->status_mail['status'] = false;
                    $this->status_mail['message'] = "Server denied RSET command";
                    return false;
                }
                if ($key_res != 'webi')
                {
                    unset($this->headers[$key_res]);
                    unset($this->ready_headers[$key_res]);
                }
                if ($body_resource != 'webi')
                {
                    unset($this->body[$body_resource]);
                }
            }
            fputs($smtp_conn, "QUIT\r\n");
            $this->add_log("QUIT\r\n");
            $data = $this->get_data($smtp_conn)."\n";
            $this->add_log($data);
            fclose($smtp_conn);
            $this->status_mail['status'] = true;
            $this->status_mail['message'] = "Message successfully sent through SMTP";
            return true;
        }
    }
    public function Get()
    {
        if (!$this->log_on)
            return 'Logging disabled. To create log file enable logging setting $m->log_on(true);';
        
        if (strlen($this->smtp_log))
        {
            return $this->smtp_log;
        }
    }
}
?>