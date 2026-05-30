from app.extensions import db
from app.models.base_model import BaseModel
from sqlalchemy.orm import validates
from app.core.security import hash_password, verify_password
import re # used for Regular Expressions to validate complex string patterns (e.g., email format).
from email_validator import validate_email as check_email_domain, EmailNotValidError

"""
User Data Model Definition.

Acts as the Object-Relational Mapping (ORM) for the `users` table. 
This file encapsulates the user data structure and enables the Flask application 
to manage user entities through standard Pythonic interactions (CRUD) without 
raw SQL queries.
"""

class User(BaseModel):
    __tablename__ = "users"

    # core identity information
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False, index=True)
    password = db.Column(db.String(255), nullable=False)

    # Role-Based Access Control (RBAC)
    system_role = db.Column(db.String(50), default="customer")
    fcm_token = db.Column(db.String(255), nullable=True) # Firebase Cloud Messaging Token
    profile_image_url = db.Column(db.Text, nullable=True)
    is_active = db.Column(db.Boolean, default=True)


    # ==========================================
    # Validation Methods 
    # ==========================================

    # key: the name of column we try to save data into
    # value: the data itself
    
    # ----------------- validate for name -----------------
    @validates("name")
    def validate_name(self, key, value):
        """
        Sanitizes and validates the user's display name.
        Args:
            value (str): The display name provided by the user.
        Returns:
            str: The sanitized (stripped) name.

        raises:
            ValueError: if the name is missing, not a string, or not between 3-255 characters.
        """
        if not value or not isinstance(value, str):
            raise ValueError("Name is required and must be text.")
        # to removes any leading (front) or trailing (end) whitespace (spaces) from a string.
        clean_name = value.strip()
        
        if len(clean_name) < 3 or len(clean_name) > 255:
            raise ValueError("Name must be between 3 and 255 characters.")
        
        return clean_name
    
    # ----------------- validate for email -----------------
    @validates("email")
    def validate_email(self, key, value):
        """
        Normalizes and validates the email address format.
        Args:
            value (str): The raw email address provided by the user.
        Returns:
            str: The normalized (lowercase and stripped) email.

        raises:
            ValueError: if the email is missing, malformed, or the domain doesn't exist.
        """
        if not value:
            raise ValueError("Email is required.")
        
        # Data Normalization:
        # Strips accidental spaces and converts to lowercase to prevent case-sensitivity 
        # issues in PostgreSQL. This ensures reliable logins and prevents users 
        # from creating duplicate accounts (e.g., 'User@loven.com' vs 'user@loven.com').
        clean_email = value.strip().lower()

        try:
            # 1. Verifies email syntax and domain existence (DNS/MX records).
            # 2. Normalizes the email to a safe, standardized format (handles Punycode/case-sensitivity).
            validation_info = check_email_domain(clean_email, check_deliverability=True)
            normalized_email = validation_info.normalized
            return normalized_email
        except EmailNotValidError as e:
            # 3. Catch specific library errors and raise a standard ValueError for the Service layer.
            raise ValueError(str(e))

    # ----------------- validate for role -----------------
    @validates("system_role")
    def validate_system_role(self, key, value):
        """
        Restricts the user's system role to the allowed whitelist.
        Args:
            value (str): The system role assigned to the user.
        Returns:
            str: The validated system role.

        raises:
            ValueError: if the role is not within the allowed list (customer, artist, admin).
        """
        allowed_roles = ["customer", "artist", "admin"]

        if value not in allowed_roles:
            raise ValueError(f"Invalid system role. Allowed roles are: {', '.join(allowed_roles)}")
        return value
    
    # ----------------- validate for password -----------------
    @validates("password")
    def validate_and_hash_password(self, key, value):
        """
        Validates the password strength and hashes it before storage.
        Args:
            value (str): The plain-text password provided by the user.
        Returns:
            str: the securely hashed password.

        raises:
            ValueError: if the password is missing or shorter than 8 char.
        """
        if not value:
            raise ValueError("Password is required.")
        
        # Avoid double-hashing:
        # If the value starts with the bcrypt signature '$2b$' and has sufficient length,
        # it means the password is already hashed (e.g., during a DB refresh). 
        # We return it as-is to prevent hashing a hash.
        if value.startswith(("$2a$", "$2b$", "$2y$")) and len(value) >= 50:
            return value
        
        # Password Complexity Regex:
        # (?=.*[a-z]) : At least one lowercase letter
        # (?=.*[A-Z]) : At least one uppercase letter
        # (?=.*\d)    : At least one digit (number)
        # (?=.*[\W_]) : At least one special character (non-word character or underscore)
        # .{8,}       : Minimum length of 8 characters
        password_regex = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$"
        if not re.match(password_regex, value):
            raise ValueError(
                "Password must be at least 8 characters long and include an uppercase letter, "
                "a lowercase letter, a number, and a special character."
            )
        # Encrypt the plain-text password using the security.py 
        return hash_password(value)
    
    def check_password(self, plain_password):
        """
        Verifies a plain-text password against the stored hash in the database.
        """
        if not self.password:
            return False
        
        if not self.password.startswith(("$2a$", "$2b$", "$2y$")):
            return False
        
        try:
            return verify_password(plain_password, self.password)
        except ValueError:
            return False
    
    def __repr__(self):
        return f"<User(email={self.email}, role={self.system_role})>"