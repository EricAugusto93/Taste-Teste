class AuthValidators {
  static String? email(String? value) {
    return validateEmail(value);
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  static String? password(String? value) {
    return validatePassword(value);
  }

  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Senha deve conter pelo menos um número';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    return validateConfirmPassword(value, password);
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    
    if (value != password) {
      return 'Senhas não coincidem';
    }
    
    return null;
  }

  static String? name(String? value) {
    return validateName(value);
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    return null;
  }

  static String? phone(String? value) {
    return validatePhone(value);
  }

  static String? phoneOptional(String? value) {
    return validatePhoneOptional(value);
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    final phoneRegex = RegExp(r'^\([1-9]{2}\) [9]{0,1}[0-9]{4}-[0-9]{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Telefone inválido. Use o formato (11) 99999-9999';
    }
    
    return null;
  }

  static String? validatePhoneOptional(String? value) {
    // Se o campo estiver vazio, é válido (opcional)
    if (value == null || value.isEmpty) {
      return null;
    }
    
    // Se preenchido, valida o formato
    final phoneRegex = RegExp(r'^\([1-9]{2}\) [9]{0,1}[0-9]{4}-[0-9]{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Telefone inválido. Use o formato (11) 99999-9999';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    
    return null;
  }
}