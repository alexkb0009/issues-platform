from app.state import app
from app.includes.bottle import request, response, redirect, static_file, jinja2_view as view

## Static Theme Files

# JavaScripts
@app.route('/js/<filename:re:.*\.js>')
@app.route('/js/<path:path>/<filename:re:.*\.js>')
def javascripts(filename, path = ""):
    if path != "": path = "/" + path
    return static_file(filename, root='view/js' + path)

# Stylesheets
@app.route('/css/<filename:re:.*\.css>')
@app.route('/css/<path:path>/<filename:re:.*\.css>')
def stylesheets(filename, path = ""):
    if path != "": path = "/" + path
    return static_file(filename, root='view/css' + path)

# Images
@app.route('/img/<filename:re:.*\.(jpg|png|gif|ico)>')
@app.route('/img/<path:path>/<filename:re:.*\.(jpg|png|gif|ico)>')
def images(filename, path = ""):
    if path != "": path = "/" + path
    return static_file(filename, root='view/images' + path)

# WebFonts
@app.route('/font/<filename:re:.*\.(ttf|eot|svg|woff|otf|css|woff2)>')
@app.route('/font/<path:path>/<filename:re:.*\.(ttf|eot|svg|woff|otf|css|woff2)>')
def images(filename, path = ""):
    if path != "": path = "/" + path
    return static_file(filename, root='view/webfonts' + path)  