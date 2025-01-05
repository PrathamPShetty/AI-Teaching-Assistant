import ollama
from langchain_core.prompts import PromptTemplate

# Base template for explaining math and science problems step by step
base_template = """
You are an AI Teaching Assistant that explains math and science problems in simple words for students. Your goal is to make complex problems easy to understand by breaking them down into step-by-step solutions.

**Problem to Explain**: {problem}

### Instructions:
1. **Understand the Problem**: Analyze the problem and identify what is being asked.
2. **Break It Down**: Provide a step-by-step explanation of how to solve the problem.
3. **Use Simple Language**: Explain each step in simple, easy-to-understand language.
4. **Provide Examples**: If applicable, include examples or analogies to help students understand.
5. **Final Answer**: Clearly state the final answer or solution.

### Output Format:
Problem: [The problem to solve]
Step 1: [Explanation of the first step]
Step 2: [Explanation of the second step]
...
Final Answer: [The final answer or solution]
"""



def create_problem_prompt_template(problem):
    """
    Create a prompt template for explaining math and science problems.

    Args:
        problem (str): The problem to explain.

    Returns:
        str: A formatted prompt string ready for the AI system.
    """
    prompt_template = PromptTemplate(
        input_variables=["problem"],
        template=base_template
    )
    return prompt_template.format(problem=problem)
