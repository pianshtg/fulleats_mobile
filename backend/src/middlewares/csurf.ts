import csrf from "csurf";
import { NextFunction, Request, Response } from "express";

declare global {
    namespace Express {
      interface Request {
        csrfToken(): string;
      }
    }
  }

const csrfConfig = csrf({
    cookie: {
        httpOnly: false,
        secure: process.env.ENVIRONMENT as string === 'production',
        sameSite: process.env.ENVIRONMENT as string === 'production' ? 'none' : 'lax'
    }
})

export const csrfProtection = (req: Request, res: Response, next: NextFunction) => {
  
    // Skipping CSRF protection for specific routes
    if (req.path === '/api/auth/verify-email' || req.path === '/') {
      return next() // Skipping CSRF protection for this route
    }
  
  const clientType = req.headers['x-client-type'] // Getting client type from headers

  if (clientType === 'mobile') {
      return next() // Skipping CSRF protection for mobile clients
  } else if (clientType === 'web') {
      csrfConfig(req, res, next) // Applying CSRF protection for web clients
  } else {
      res.status(401).json({message: 'Unauthorized.'})
      return
  }
}

export const csrfToken = (req: Request, res: Response) => {
  res.json({csrfToken: req.csrfToken()})
}