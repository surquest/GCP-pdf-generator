from os import getenv
from fastapi import APIRouter, Response
from weasyprint import HTML, CSS

router = APIRouter()

@router.post(
    "/PDF/generate",
    name="Generate PDF document",
    tags=["PDF"],
    operation_id="generate_pdf_document"
)
def generate_pdf_document(

):

    # import docx file from location "templates/examples/docx/invoice.docx"
    ROOT = getenv("ROOT_DIR")
    html_template_path = F"{ROOT}/templates/examples/html/invoice.html"
    css_template_path = F"{ROOT}/templates/examples/html/invoice.css"

    headers = {'Content-Disposition': 'attachment; filename="out.pdf"'}
    pdf_content = HTML(html_template_path).write_pdf(
        # stylesheets=[CSS(css_template_path)]
    )
    
    return Response(
        pdf_content,
        headers=headers, 
        media_type='application/pdf'
        )
