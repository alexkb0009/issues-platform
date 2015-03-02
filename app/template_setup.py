from app.includes.bottle import Jinja2Template, url
from app.state import app
from app.functions import sort

Jinja2Template.defaults = {
    'url' : url,
    'site_name' : app.config['app_info.site_name'],
    'root' : app.config['app_info.root_directory'],
    'issue_scale_options' : sort.getIssuesScaleOptions,
    'issue_sort_options' : sort.getIssuesSortOptions
}