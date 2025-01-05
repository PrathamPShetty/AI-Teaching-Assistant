import streamlit as st
import requests

# Page Configuration
st.set_page_config(page_title="AI Judge Query Interface", layout="centered", page_icon="⚖️")

# Styling with CSS
st.markdown("""
    <style>
        body {
            background-color: #1a202c;
            color: #f0f0f0;
            font-family: 'Roboto', sans-serif;
        }
        .chat-container {
            max-height: 400px;
            overflow-y: auto;
            background-color: #2d3748;
            box-shadow: 0px 4px 15px rgba(0, 0, 0, 0.5);
            border-radius: 10px;
            padding: 15px;
        }
        .user-message {
            background-color: #4a90e2;
            color: white;
            padding: 10px;
            border-radius: 10px;
            margin: 5px 0;
        }
        .bot-message {
            background-color: #2b2b2b;
            color: #00d9a7;
            padding: 10px;
            border-radius: 10px;
            margin: 5px 0;
        }
    </style>
""", unsafe_allow_html=True)

# Header
st.title("⚖️ AI Judicial System")
st.write("""
Welcome to the **Future of Fairness**!  
Our intelligent judicial assistant bridges the gap between complexity and clarity.  
Ask questions, get insights, and simplify your legal inquiries with AI-powered assistance.
""")

# Chat Interface
st.subheader("💬 Chat with AI Judge")

# Chat History
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

chat_container = st.container()
for chat in st.session_state.chat_history:
    if chat['user']:
        chat_container.markdown(f"<div class='user-message'>{chat['message']}</div>", unsafe_allow_html=True)
    else:
        chat_container.markdown(f"<div class='bot-message'>{chat['message']}</div>", unsafe_allow_html=True)

# User Input
user_input = st.text_area("Type your Case Description:", key="user_input", placeholder="Ask me anything about legal matters...", height=100)

# Handle User Input
if st.button("Send"):
    if user_input.strip():
        # Append User Message
        st.session_state.chat_history.append({"user": True, "message": user_input})
        chat_container.markdown(f"<div class='user-message'>{user_input}</div>", unsafe_allow_html=True)

        # Call the API
        api_url = "http://127.0.0.1:8000/evaluate"  # Replace with your backend URL if hosted remotely
        try:
            response = requests.post(api_url, json={"case_description": user_input})
            if response.status_code == 200:
                bot_response = response.json().get("evaluation_result", "No response from AI Judge.")
            else:
                bot_response = f"Error: {response.status_code} - {response.text}"
        except Exception as e:
            bot_response = f"API Error: {e}"

        # Append Bot Response
        st.session_state.chat_history.append({"user": False, "message": bot_response})
        chat_container.markdown(f"<div class='bot-message'>{bot_response}</div>", unsafe_allow_html=True)

        # Clear input box
        st.rerun()


# Footer
st.markdown("---")
st.write("📜 **AI Judge Interface © 2024**")
