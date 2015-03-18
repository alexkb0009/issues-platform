from app.state import app

def email(to, subject, message, toName = None, fromEmail = 'messages@myissues.us', fromName = None, isHTML = False):

    # Sendgrid
    
    if app.config['email.mode'] == 'sendgrid':
        import requests
        params = {}
        params['api_user']  = app.config['email.sendgrid_api_user']
        params['api_key']   = app.config['email.sendgrid_api_key']
        params['to']        = to
        params['subject']   = subject
        params['toname']    = toName
        params['from']      = fromEmail
        params['fromname']  = fromName or app.config.get('app_info.site_name')
        params['bcc']       = app.config['reporting.report_email']
        
        if isHTML:
            params['html']  = message
        else:
            params['text']  = message
            
        if app.config.get('email.replyto_email'):
            params['replyto'] = app.config.get('email.replyto_email')
            
        sendgrid_response = requests.post(app.config['email.sendgrid_api_url'], params)
        print(sendgrid_response.text)
        return sendgrid_response.status_code == requests.codes.ok
        
    # SMTP Server
    
    else:
        from smtplib import SMTP_SSL as SMTP
        from email.mime.text import MIMEText

        mime_message = MIMEText(message)
        mime_message['Subject'] = subject
        mime_message['To'] = to
        
        try:
            connection = SMTP(app.config['reporting.smtp_server'])
            connection.set_debuglevel(True)
            connection.login(app.config['reporting.smtp_username'], app.config['reporting.smtp_password'])    
            try:
                connection.sendmail(app.config['reporting.from_email'], app.config['reporting.report_email'], message.as_string())
                print('Seems to have sent successfully.')
            finally:
                connection.close()
                return True
        except Exception as exc:
            print('Couldnt send email.')
            print(exc)
            return False