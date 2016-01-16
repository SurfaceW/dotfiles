import sys
import urllib
from workflow import Workflow, ICON_WEB, web

def main(wf):

    if len(wf.args):
        query = wf.args[0]
    else:
        query = None

    imdbURL = 'http://www.imdb.com/title/'

    moviesData = web.get('http://www.omdbapi.com/?s=' + urllib.quote(query) + '&r=json').json()

    if 'Response' in moviesData:
        wf.add_item(title = 'No movie was found.')
    elif 'Search' in moviesData:
        for movie in moviesData['Search']:
            wf.add_item(title = '%s (%s)' % (movie['Title'], movie['Year']),
                        arg = imdbURL + movie['imdbID'],
                        valid = True,
                        )

    wf.send_feedback()

if __name__ == u"__main__":
    wf = Workflow()
    sys.exit(wf.run(main))