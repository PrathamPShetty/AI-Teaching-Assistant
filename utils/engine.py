import ollama
from langchain_core.prompts import PromptTemplate
from prompt import create_problem_prompt_template

def ai_teaching_assistant(problem):
    """
    Function to interact with the AI model for explaining math and science problems.

    Args:
        problem (str): The problem to explain (e.g., "Solve 2x + 5 = 15").

    Returns:
        str: The structured explanation from the model.
    """
    # Prepare the message payload for the API call
    messages = [
        {
            'role': 'user',
            'content': create_problem_prompt_template(problem)
        },
    ]
    
    try:
        # Call the AI model
        response = ollama.chat(model='llama3.2:1b', messages=messages)

        if 'message' in response and 'content' in response['message']:
            return response['message']['content']
        else:
            raise ValueError("Unexpected response structure.")

    except Exception as e:
        raise RuntimeError(f"An error occurred: {str(e)}")



def ask_with_image(image_base64, question):
    """
    Send an image and a question to the AI model.

    Args:
        image_path (str): Path to the image file.
        question (str): The question to ask about the image.

    Returns:
        str: The model's response.
    """
 
    messages = [
            {
               'role': 'user',
               'content': create_problem_prompt_template(image_base64)
            }
        ]


    try:
        response = ollama.chat(model='llama3.2:1b', messages=messages)

        if 'message' in response and 'content' in response['message']:
            return response['message']['content']
        else:
            raise ValueError("Unexpected response structure.")

    except Exception as e:
        raise RuntimeError(f"An error occurred: {str(e)}")




if __name__ == "__main__":
    # Ask the AI to explain a math problem
    math_problem = "Solve 2x + 5 = 15"
    math_explanation = ai_teaching_assistant(math_problem)
    print("Math Problem Explanation:")
    print(math_explanation)

    # Ask the AI to explain a science problem
    science_problem = "Explain why the sky appears blue."
    science_explanation = ai_teaching_assistant(science_problem)
    print("\nScience Problem Explanation:")
    print(science_explanation)

# 
  
# def generate_image(description):
#     """
#     Generate an image based on the description using DALL·E.

#     Args:
#         description (str): The image description.

#     Returns:
#         str: URL of the generated image.
#     """
 
#     response = client.images.generate(
#         model="dall-e-3",
#         prompt=description,
#         size="1024x1024",
#         quality="standard",
#         n=1,
#     )
#     return response.data[0].url

    # if "Image Description:" in explanation:
    #     image_description = explanation.split("Image Description:")[1].strip()
    #     image_url = generate_image(image_description)
    #     print(f"Generated Image URL: {image_url}")