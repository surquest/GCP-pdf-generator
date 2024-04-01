from os import getenv
from surquest.utils.config.formatter import Formatter

__all__ = ["formatter"]

CLOUD = "GCP"
ENV = getenv("ENV", "PROD")
WORKING_DIR = getenv("ROOT_DIR", "/app")

formatter = Formatter(
    config={
        "GCP": Formatter.load_json(path=F"{WORKING_DIR}/config/{CLOUD}/project.{ENV}.json"),
        "solution": Formatter.load_json(path=F"{WORKING_DIR}/config/solution.json"),
        "services": {
            "storage": Formatter.load_json(path=F"{WORKING_DIR}/config/{CLOUD}/services/storage.buckets.json").get("storage"),
            "iam": Formatter.load_json(path=F"{WORKING_DIR}/config/{CLOUD}/services/iam.serviceAccounts.json").get("iam")
        }
    },
    naming_patterns=Formatter.load_json(
        path=F"{WORKING_DIR}/config/naming.patterns.json"
    )
)
