const fs = require('fs');
const file = 'C:/Users/chaga/OneDrive/Documents/My Tableau Repository/Desktop/creators_grow_backend/src/controllers/auth.controller.ts';
let code = fs.readFileSync(file, 'utf8');

code = code.replace(
  '  register = async (req: Request, res: Response, next: NextFunction) => {',
  '  register = async (req: Request, res: Response, next: NextFunction) => {\n    console.log(\'AUTH_REGISTER_RECEIVED\');'
);
code = code.replace(
  '      const { email, password, displayName } = parsed.data;',
  '      console.log(\'AUTH_REGISTER_VALIDATION_OK\');\n      const { email, password, displayName } = parsed.data;\n      console.log(\'AUTH_REGISTER_DB_START\');'
);
code = code.replace(
  '      const session = await this.authService.register(email, password, displayName);\n      return res.status(201).json(session);',
  '      const session = await this.authService.register(email, password, displayName);\n      console.log(\'AUTH_REGISTER_DB_SUCCESS\');\n      console.log(\'AUTH_REGISTER_RESPONSE_SENT\');\n      return res.status(201).json(session);'
);
code = code.replace(
  '    } catch (error) {',
  '    } catch (error) {\n      console.log(\'AUTH_REGISTER_ERROR\', error);'
);

fs.writeFileSync(file, code);
console.log('Patched auth.controller.ts');
