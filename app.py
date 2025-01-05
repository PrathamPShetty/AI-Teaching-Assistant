from fastapi import FastAPI, Request, HTTPException, File, UploadFile,Form
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel
import logging
import ollama
from langchain_core.prompts import PromptTemplate
from utils.engine import ai_teaching_assistant, ask_with_image
from utils.convertBase import image_to_base64
from PIL import Image
from io import BytesIO
import os

# Initialize FastAPI app
app = FastAPI()

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Jinja2 templates
templates = Jinja2Templates(directory="templates")

# Pydantic model for the question input
class Question(BaseModel):
    question: str

# Root endpoint to render the HTML page
@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    """
    Render the root HTML page.

    Args:
        request (Request): The HTTP request object.

    Returns:
        HTMLResponse: The rendered HTML template for the root page.
    """
    logger.info("Rendering root page.")
    return JSONResponse({"response": "Hi,am Ai Teaching Assistant"})

# Endpoint to handle text-based questions
@app.post("/question")
async def evaluate_question(question: Question):
    """
    Answer a question using the AI teaching assistant.

    Args:
        question (Question): The Pydantic model containing the question.

    Returns:
        JSONResponse: The answer or explanation from the AI teaching assistant.
    """
    logger.info(f"Received question: {question.question}")
    
    try:
        # Use the AI teaching assistant to answer the question
        answer = ai_teaching_assistant(question.question)
        print(answer)
        answer = answer.replace('**', '')
        answer = answer.replace('###', '')
     

        logger.info(f"Answer: {answer}")
        return JSONResponse(content={"answer": answer})

    except Exception as e:
        logger.error(f"Error answering question: {str(e)}")
        raise HTTPException(status_code=500, detail="An error occurred while answering the question.")

# Endpoint to handle image-based questions
@app.post("/withimage")
async def with_image(image: UploadFile = File(...),  question: str = Form(...) ):
    """
    Answer a question about an uploaded image using the AI teaching assistant.

    Args:
        file (UploadFile): The uploaded image file.
        question (str): The question to ask about the image.

    Returns:
        JSONResponse: The answer or explanation from the AI teaching assistant.
    """
    try:
        logger.info("Image file received in the POST request")

        # Read the image file
        content = await image.read()
        im = Image.open(BytesIO(content))

        # Save the image to a temporary file
        filename = "image.png"
        file_path = os.path.join("./static", filename)
        os.makedirs("./static", exist_ok=True)
        im.save(file_path)
        logger.info(f"Image saved at: {file_path}")

        # Convert the image to base64
        image_base64 = image_to_base64(file_path)

        # Use the AI teaching assistant to answer the question about the image
        answer = ask_with_image(image_base64, question)
        answer = answer.replace('**', '')
        answer = answer.replace('###', '')

        return JSONResponse(content={"answer": answer})

    except Exception as e:
        logger.error(f"Error answering question: {str(e)}")
        raise HTTPException(status_code=500, detail="An error occurred while answering the question.")

# Health check endpoint
@app.get("/healthcheck")
async def healthcheck():
    """
    Simple health check endpoint.

    Returns:
        JSONResponse: A health check message.
    """
    logger.info("Health check called.")
    return JSONResponse(content={"status": "healthy"})

# Run the FastAPI app
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)