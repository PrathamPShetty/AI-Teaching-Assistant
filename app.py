from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel, Field
import logging
import ollama
from langchain_core.prompts import PromptTemplate


app = FastAPI()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Define the Pydantic model for incoming case details
class CaseDetails(BaseModel):
    case_description: str = Field(
        ..., 
        example="Mack and Ana were seen arguing at the bungee jumping site before Mack's death. Mackenzie was also present with nunchaku."
    )

# Base template for legal case analysis
base_template = """
You are an AI Legal Advisor tasked with analyzing legal cases based on the Indian Penal Code (IPC).

**Case Description**: {description}

### Instructions for Case Analysis:
1. **Identify the suspect(s)**: Who are the possible suspects in this case?



Please respond with your analysis in the following format:
- Suspect(s): [Name of suspects]


"""


def ai_judge(prompt: str) -> str:
    """
    Function to interact with the AI Judge model for legal case analysis.
    
    Args:
        prompt (str): The case description to analyze.

    Returns:
        str: The structured judgment from the model.
    """
    # Prepare the message payload for the API call
    formatted_prompt = create_case_prompt_template(prompt)
    messages = [{'role': 'user', 'content': formatted_prompt}]
    
    try:
        # Call the AI model
        response = ollama.chat(model='llama3.2:1b', messages=messages)

        if 'message' in response and 'content' in response['message']:
            return response['message']['content']
        else:
            raise ValueError("Unexpected response structure.")

    except Exception as e:
        raise RuntimeError(f"An error occurred: {str(e)}")

def create_case_prompt_template(description: str) -> str:
    """
    Create a prompt template for legal case analysis based on the IPC.

    Args:
        description (str): The user's case description.

    Returns:
        str: A formatted prompt string ready for the legal AI system.
    """
    prompt_template = PromptTemplate(input_variables=["description"], template=base_template)
    return prompt_template.format(description=description)

# FastAPI routes

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
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/evaluate")
async def evaluate_case(case: CaseDetails):
    """
    Evaluate a legal case based on the provided details.

    Args:
        case (CaseDetails): The Pydantic model containing case description.

    Returns:
        JSONResponse: The evaluation result from the AI Judge.
    """
    logger.info(f"Received case details: {case.case_description}")
    
    try:
        # Use the AI judge engine to evaluate the case
        evaluation_result = ai_judge(case.case_description)

        logger.info(f"Evaluation Result: {evaluation_result}")
        return JSONResponse(content={"evaluation_result": evaluation_result})

    except Exception as e:
        logger.error(f"Error evaluating case: {str(e)}")
        raise HTTPException(status_code=500, detail="An error occurred while evaluating the case.")

@app.get("/healthcheck")
async def healthcheck():
    """
    Simple health check endpoint.

    Returns:
        JSONResponse: A health check message.
    """
    logger.info("Health check called.")
    return JSONResponse(content={"status": "healthy"})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
