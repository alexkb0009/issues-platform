from app.state import app, db
from app.utilities.scheduling import periodic_scheduler
import os

# Bulk Data Imports, if enabled

if app.config['data.enable_scheduled_import'].lower() == 'true' and 'data.bulk_data_files' in app.config:
    from json import loads
    from app.utilities.bulk_data_import import bulk_file_download_import
    
    periodic_scheduler(
      None, 
      int(app.config['data.bulk_import_frequency']), 
      bulk_file_download_import,
      (
        app.config,
        loads(app.config['data.bulk_data_files']),     # json.loads to convert textual array into Dict.
        db
      )
    )

    
# Clean Old/Unused Sessions from filesystem, if using file sessions

if app.config['security.sessions_type'] == 'file':
    from app.utilities.clean_sessions import cleanSessions
    periodic_scheduler(
      None, 
      60 * 60 * 24, 
      cleanSessions
    )
    
# Filter OpenShift log files

if os.environ.get('OPENSHIFT_LOGMACHINE') is not None:
    from app.utilities.filter_openshift_logs import run as filter_openshift_logs
    periodic_scheduler(
      None, 
      60 * 60 * 24, 
      filter_openshift_logs
    )
    
    
