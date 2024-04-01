# import external packages
import os
from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException
from surquest.fastapi.utils.route import Route  # custom routes for documentation and FavIcon
from surquest.fastapi.utils.GCP.middleware import LoggingMiddleware
from surquest.fastapi.utils.GCP.catcher import (
    catch_validation_exceptions,
    catch_http_exceptions,
)


# import internal packages and modules
from .config import formatter
from .routes.pdf import generate

PATH_PREFIX = os.getenv('PATH_PREFIX','')

app = FastAPI(
    title=formatter.config.get('solution').get('name'),
    description=formatter.config.get('solution').get('desc'),
    openapi_url=F"{PATH_PREFIX}/openapi.json",
    version=formatter.config.get('solution').get('version'),
)

# exception handlers
app.add_exception_handler(HTTPException, catch_http_exceptions)
app.add_exception_handler(RequestValidationError, catch_validation_exceptions)



# add routers
app.include_router(generate.router, prefix=PATH_PREFIX)


# custom routes to documentation and favicon
app.add_api_route(path=F"{PATH_PREFIX}/", endpoint=Route.get_documentation, include_in_schema=False)
app.add_api_route(path=PATH_PREFIX, endpoint=Route.get_favicon, include_in_schema=False)