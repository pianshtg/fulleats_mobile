import 'dotenv/config'
import { NextFunction, Request, Response } from 'express'
import jwt from 'jsonwebtoken'
import { pool } from '../database'
import { RowDataPacket } from 'mysql2'
import bcrypt from 'bcrypt'

// Defining custom request
declare global {
    namespace Express {
        interface Request {
            accessToken?: string,
            refreshToken?: string,
            newAccessToken?: string
        }
    }
}

export function generateAccessToken (data: any) {
    // Generating new access token
    return jwt.sign(data, process.env.ACCESS_TOKEN_SECRET_KEY as string, {expiresIn: '15m'})
}

export function generateRefreshToken (data: any) {
    // Generating new refresh token
    return jwt.sign(data, process.env.REFRESH_TOKEN_SECRET_KEY as string, {expiresIn: '7d'})
}

export async function clientType(req: Request, res: Response, next: NextFunction) {       
    try {
        const clientType = req.headers['x-client-type']
        let accessToken: string | undefined
        let refreshToken: string | undefined
        
        if (clientType === 'web') {
            accessToken = req.cookies.accessToken
            refreshToken = req.cookies.refreshToken
        } else if (clientType === 'mobile') {
            // Fetching the refresh token from header and checking the request input
            const refreshTokenHeader = req.headers['x-refresh-token']
            if (Array.isArray(refreshTokenHeader)) {
                refreshToken = refreshTokenHeader[0]; // Using the first value if it's an array
            } else {
                refreshToken = refreshTokenHeader; // It's either a string or undefined
            }
            const authHeader = req.headers.authorization
            if (authHeader && authHeader.startsWith('Bearer ')) {
                accessToken = authHeader.split(' ')[1]
            }
        }

        // Checking if there's a refresh token
        if (!refreshToken) {
            res.status(401).json({message: "Invalid refresh token."})
            return
        }

        // Setting the access and refresh token
        req.accessToken = accessToken
        req.refreshToken = refreshToken
        
        next()
        
    } catch (error) {
        console.error("Error fetching client type:", error) // Debug.
        res.status(401).json({message: "Error fetching client type"})
    }
}

export async function jwtCheck(req: Request, res: Response, next: NextFunction) {

    try {
        const accessToken = req.accessToken

        // If there's an access token, validating it normally, otherwise (else statement)
        if (accessToken && jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET_KEY as string)) {
            next()
        } else {
            let refreshToken = req.refreshToken
            if (refreshToken) {
                // If there's no access token but there is a refresh token, trying to renew the access token
                // Decoding the refresh token
                try {
                    const decodedRefreshToken = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET_KEY as string) as jwt.JwtPayload;
    
                    // Checking if the user has the refresh token in the database
                    const [user_hashed_refresh_token] = await pool.execute<RowDataPacket[]>('SELECT hashed_refresh_token FROM users_hashed_refresh_token WHERE user_id = ?', [decodedRefreshToken.user_id]);
                    if (user_hashed_refresh_token.length === 0) {
                        res.status(401).json({ message: "Unauthorized." });
                        return
                    }
    
                    // Comparing the refresh token to the one stored in the database
                    const isValidRefreshToken = await bcrypt.compare(refreshToken, user_hashed_refresh_token[0].hashed_refresh_token);
                    if (!isValidRefreshToken) {
                        res.status(401).json({ message: "Invalid refresh token." });
                        return
                    }
    
                    // If valid, generating a new access token
                    const user_id = decodedRefreshToken.user_id;
                    const permissions = decodedRefreshToken.permissions;
                    const nama_mitra = decodedRefreshToken.nama_mitra || undefined;
    
                    // Creating a new access token
                    const newAccessToken = generateAccessToken({ user_id, permissions, nama_mitra });
    
                    // Setting the new access token into the cookie jar for web clients
                    const clientType = req.headers['x-client-type'];
                    if (clientType === 'web') {
                        res.cookie('accessToken', newAccessToken, {
                            secure: process.env.ENVIRONMENT as string === 'production',
                            sameSite: process.env.ENVIRONMENT as string === 'production' ? 'none' : 'lax',
                            maxAge: 15 * 60 * 1000,  // 15 minutes
                            path: '/'
                        });
                    } else {
                        // If mobile, sending the new access token into the response body
                        req.newAccessToken = newAccessToken;
                    }
    
                    next(); // Proceeding to the next middleware or controller
                    
                } catch (error) {
                    res.status(401).json({ message: "Unauthorized." });
                    return
                }
            } else {
                res.status(401).json({ message: "Unauthorized." });
                return
            }
        }
        
    } catch (error) {
        if (error instanceof jwt.TokenExpiredError) {
            let refreshToken = req.refreshToken
            if (refreshToken) {
                // If there's the access token is expired and there is a refresh token, trying to renew the access token
                // Decoding the refresh token
                try {
                    const decodedRefreshToken = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET_KEY as string) as jwt.JwtPayload;
    
                    // Checking if the user has the refresh token in the database
                    const [user_hashed_refresh_token] = await pool.execute<RowDataPacket[]>('SELECT hashed_refresh_token FROM users_hashed_refresh_token WHERE user_id = ?', [decodedRefreshToken.user_id]);
                    if (user_hashed_refresh_token.length === 0) {
                        res.status(401).json({ message: "Unauthorized." });
                        return
                    }
    
                    // Comparing the refresh token to the one stored in the database
                    const isValidRefreshToken = await bcrypt.compare(refreshToken, user_hashed_refresh_token[0].hashed_refresh_token);
                    if (!isValidRefreshToken) {
                        res.status(401).json({ message: "Invalid refresh token." });
                        return
                    }
    
                    // If valid, generating a new access token
                    const user_id = decodedRefreshToken.user_id;
                    const permissions = decodedRefreshToken.permissions;
                    const nama_mitra = decodedRefreshToken.nama_mitra || undefined;
    
                    // Creating a new access token
                    const newAccessToken = generateAccessToken({ user_id, permissions, nama_mitra });
    
                    // Setting the new access token into the cookie jar for web clients
                    const clientType = req.headers['x-client-type'];
                    if (clientType === 'web') {
                        res.cookie('accessToken', newAccessToken, {
                            secure: process.env.ENVIRONMENT as string === 'production',
                            sameSite: process.env.ENVIRONMENT as string === 'production' ? 'none' : 'lax',
                            maxAge: 15 * 60 * 1000,  // 15 minutes
                            path: '/'
                        });
                    } else {
                        // If mobile, sending the new access token into the response body
                        req.newAccessToken = newAccessToken;
                    }
    
                    next(); // Proceeding to the next middleware or controller
                    
                } catch (error) {
                    res.status(401).json({ message: "Unauthorized." });
                    return
                }
            } else {
                res.status(401).json({ message: "Unauthorized." });
                return
            }
        }
        
    }
}
