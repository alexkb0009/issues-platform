from app.includes.bottle import Jinja2Template, url, request
from app.state import app
from app.functions import sort, issues
from app.utilities import disqus

Jinja2Template.defaults = {
    'url' : url,
    'site_name' : app.config['app_info.site_name'],
    'site_domain' : app.config['app_info.site_domain'],
    'root' : app.config['app_info.root_directory'],
    'path' : lambda: request.get('PATH_INFO'),
    'issue_scale_options' : sort.getIssuesScaleOptions,
    'issue_sort_options' : sort.getIssuesSortOptions,
    'issue_visibility_options' : issues.getIssueVisibilityOptions,
    'disqus_sso_js' : disqus.get_disqus_sso_js
    
}