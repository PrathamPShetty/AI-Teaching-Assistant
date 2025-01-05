# Import necessary libraries
import ollama
from langchain_core.prompts import PromptTemplate

# Base template for explaining concepts in simple words
base_template = """
You are an AI Teaching Assistant that explains concepts in simple words for students. Your goal is to make complex subject ideas easy to understand.

**Concept to Explain**: {concept}

### Instructions:
1. **Define the Concept**: Explain the concept in simple, easy-to-understand language.
2. **Provide Examples**: Give a real-life example to help students relate to the concept.
3. **Provide Images**: If needed, suggest an image description to help students visualize the concept.
4. **Keep It Short**: Your explanation should be concise and to the point.

### Output Format:
Concept: [Name of the concept]
Definition: [Simple definition]
Example: [Real-life example]
Image Description: [Description of an image to help visualize the concept, if applicable]
"""

def ai_teaching_assistant(concept):
    """
    Function to interact with the AI model for explaining concepts.

    Args:
        concept (str): The concept to explain (e.g., "What is gravity?").

    Returns:
        str: The structured explanation from the model.
    """
    # Prepare the message payload for the API call
    messages = [
        {
            'role': 'user',
            'content': create_concept_prompt_template(concept)
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

def create_concept_prompt_template(concept):
    """
    Create a prompt template for explaining concepts.

    Args:
        concept (str): The concept to explain.

    Returns:
        str: A formatted prompt string ready for the AI system.
    """
    prompt_template = PromptTemplate(
        input_variables=["concept"],
        template=base_template
    )
    return prompt_template.format(concept=concept)

# Example usage
if __name__ == "__main__":
    # Ask the AI to explain a concept
    concept_to_explain = "What is gravity?"
    explanation = ai_teaching_assistant(concept_to_explain)
    print(explanation)