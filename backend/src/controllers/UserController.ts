import 'dotenv/config'
import { Request, Response } from "express";
import { pool } from "../database";
import { RowDataPacket } from "mysql2";
import {v4 as uuidv4} from 'uuid'
import jwt from 'jsonwebtoken'
import nodemailer from 'nodemailer'
import bcrypt from 'bcrypt'
import { logger } from '../lib/utils';

async function createUser(req: Request, res: Response) {
    const connection = await pool.getConnection()
    try {
        const accessToken = req.accessToken
        const newAccessToken = req.newAccessToken
        const metaData = jwt.decode(accessToken!) as jwt.JwtPayload
        const permissions = metaData.permissions
        const creator_id = metaData.user_id
        
        if (permissions.includes('create_user')) {
            // Begin transaction
            await connection.beginTransaction()
            // Get request parameters
            const {nama_lengkap, email, nomor_telepon, nama_mitra} = req.body
            
            // Checking mitra
            const [mitra] = await connection.execute<RowDataPacket[]>('SELECT id FROM mitra WHERE nama = ?', [nama_mitra])
            if (mitra.length === 0) {
                res.status(409).json({message : "Mitra doesn't exist."})
                return
            }

            // Check if user exists
            const [user] = await connection.execute<RowDataPacket[]>('SELECT * FROM users WHERE email = ?', [email])
            if (user.length > 0) {
                res.status(409).json({message: "User already exists."})
                return;
            }
            
            // Insertion of created user to users table
            const user_id = uuidv4()
            const verificationToken = uuidv4()
            await connection.execute('INSERT INTO users (id, role_id, email, nama_lengkap, nomor_telepon, verification_token, created_by) VALUES (?, (SELECT id FROM roles WHERE nama = "mitra"), ?, ?, ?, ?, ?)', [user_id, email, nama_lengkap, nomor_telepon, verificationToken, creator_id])
            
            // Insertion of user's generated password
            const new_password = uuidv4()
            const hashed_new_password = await bcrypt.hash(new_password, 10)
            await connection.execute('INSERT INTO users_hashed_password (user_id, hashed_password, created_by) VALUES (?, ?, ?)', [user_id, hashed_new_password, creator_id])

            // Insertion of created user into mitra_users table
            const mitra_id = mitra[0].id
            const mitra_users_id = uuidv4()
            await connection.execute('INSERT INTO mitra_users (id, mitra_id, user_id, created_by) VALUES (?, ?, ?, ?)', [mitra_users_id, mitra_id, user_id, creator_id])
            
            // Commit all the queries
            await connection.commit()
            
            // Delivering the verification email to the user process
                // Creating the transporter
            const transporter = nodemailer.createTransport({
                host: 'smtp.gmail.com',
                port: 587,
                secure: false,
                auth: {
                    user: process.env.TRANSPORTER_EMAIL as string,
                    pass: process.env.TRANSPORTER_PASSWORD as string
                },
                connectionTimeout: 30000 // 30 seconds
            })
                // Creating the verification token and url
            const verificationUrl = `${process.env.BASE_URL}/api/auth/verify-email?token=${verificationToken}`

                // Sending the email
            await transporter.sendMail({
                from: process.env.TRANSPORTER_EMAIL as string,
                to: email,
                subject: "Email Verification",
                html: `<h1>Please verify your email by clicking on the following link:<br></h1><a href="${verificationUrl}"><h2>Verify Email</h2></a><h3>Password: <b>${new_password}</b></h3>`
            })

            res.status(201).json({
                message: "User created successfully. Check the email verification to verify the account.",
                created_user: {
                    nama_mitra,
                    mitra_id,
                    user_id,
                    nama_lengkap,
                    email,
                    newAccessToken
                }
            })
            
            await logger({
                rekaman_id: user_id, 
                user_id: creator_id, 
                nama_tabel: 'users', 
                perubahan: {email, nama_lengkap, nomor_telepon}, 
                aksi: 'insert'
            })
            
            return

        } else {
        // User doesn't have the permissions.
            res.status(401).json({message: "Unauthorized."})
            return
        }

    } catch (error) {
        // Rollback the connection if there's error.
        await connection.rollback()
        res.status(500).json({message: "Error creating user."})
        return
    } finally {
        connection.release()
    }

}

async function getUser(req: Request, res: Response) {
    try {
        const accessToken = req.accessToken
        const newAccessToken = req.newAccessToken
        const metaData = jwt.decode(accessToken!) as jwt.JwtPayload
        const permissions = metaData.permissions

        if (permissions.includes('get_user')) {
            // Checking if the user exists in the database.
            const [user] = await pool.execute<RowDataPacket[]>('SELECT * FROM users WHERE id = ?', [metaData.user_id])
            if (user.length === 0) {
                res.status(409).json({message: "User not found."})
                return
            } else {
                res.status(200).json({
                    user: user[0],
                    newAccessToken
                })
                return
            }
        } else {
            res.status(401).json({message: "Unauthorized."})
            return
        }
        
    } catch (error) {
        res.status(500).json({message: "Error reading user."})
        return
    }
}

async function getUsers(req: Request, res: Response) {
    try {
        const accessToken = req.accessToken
        const newAccessToken = req.newAccessToken
        const metaData = accessToken ? jwt.decode(accessToken!) as jwt.JwtPayload : jwt.decode(newAccessToken!) as jwt.JwtPayload
        const permissions = metaData.permissions
        
        if (permissions.includes('view_all_user')) {
            // Retrieving all users.
            const [users] = await pool.execute<RowDataPacket[]>('SELECT * FROM users')
            if (users.length > 0) {
                res.status(200).json({
                    message: "Successfully retrieved all users.",
                    users,
                    newAccessToken
                })
                return
            } else {
                res.status(409).json({message: "No user found."})
                return
            }
        } else {
            res.status(401).json({message: "Unauthorized."})
            return
        }
    } catch (error) {
        res.status(500).json({message: "Error getting users."})
        return
    }
}

async function updateUser(req: Request, res: Response) {
    try {
        const accessToken = req.accessToken
        const newAccessToken = req.newAccessToken
        const metaData = jwt.decode(accessToken!) as jwt.JwtPayload
        const userId = metaData.user_id
        const permissions = metaData.permissions

        
        if (permissions.includes('update_user')) {
            const {nama_lengkap, email, nomor_telepon, status} = req.body
            
            // Checking if the user exists in the database and retrieving its information if it does.
            const [existingUser] = await pool.execute<RowDataPacket[]>('SELECT * FROM users WHERE id = ?', [userId])
            if (existingUser.length > 0) {
                
                // Updating user's information
                let updatedUser;
                if (!metaData.nama_mitra && status && status === 1) {
                    await pool.execute("UPDATE users SET nama_lengkap = ?, nomor_telepon = ?, is_verified = ?, updated_by = ? WHERE email = ?", [nama_lengkap, nomor_telepon, true, userId, email])
                } else {
                    await pool.execute("UPDATE users SET nama_lengkap = ?, nomor_telepon = ?, updated_by = ? WHERE email = ?", [nama_lengkap, nomor_telepon, userId, email])
                }
                
                [updatedUser] = await pool.execute<RowDataPacket[]>('SELECT * FROM users WHERE email = ?', [email])
                
                await logger({
                    rekaman_id: updatedUser[0].id,
                    user_id: userId,
                    nama_tabel: 'users',
                    perubahan: !metaData.nama_mitra && status && status === 1 ? {nama_lengkap, nomor_telepon, status} : {nama_lengkap, nomor_telepon},
                    aksi: 'update'
                })
                
                res.status(201).json({
                    message: "Successfully updated user.",
                    status: status,
                    newAccessToken
                })
                return
                
            } else {
                res.status(409).json({message: "Failed to find user."})
                return
            }
            
        } else {
            res.status(401).json({message: "Unauthorized."})
            return
        }
    } catch (error) {
        res.status(500).json({message: "Error updating mitra."})
        return
    }
}

// Soft Delete
async function deleteUser(req: Request, res: Response) {
    try {
        const accessToken = req.accessToken
        const newAccessToken = req.newAccessToken
        const metaData = jwt.decode(accessToken!) as jwt.JwtPayload
        const userId = metaData.user_id
        const permissions = metaData.permissions
        
        if (permissions.includes('delete_user')) {
            const {email} = req.body
            
            const [existingUser] = await pool.execute<RowDataPacket[]>('SELECT * FROM users WHERE email = ?', [email])
            if (existingUser.length > 0) {
                // Soft-deleting user
                await pool.execute("UPDATE users SET is_active = ?, deleted_at = CURRENT_TIMESTAMP, updated_by = ? WHERE email = ?", [false, userId, email])
                
                const [deletedUser] = await pool.execute<RowDataPacket[]>('SELECT id FROM users WHERE email = ?', [email])
                
                await logger({
                    rekaman_id: deletedUser[0].id,
                    user_id: userId,
                    nama_tabel: 'users',
                    perubahan: {},
                    aksi: 'delete'
                })
                
                res.status(201).json({
                    message: "Successfully deleted user.",
                    newAccessToken
                })
                return
                
            } else {
                res.status(409).json({message: "Failed to find user."})
                return
            }
        } else {
            res.status(401).json({message: "Unauthorized."})
            return
        }
    } catch (error) {
        res.status(500).json({message: "Error deleting user."})
        return
    }
}

export default {
    createUser,
    getUser,
    getUsers,
    updateUser,
    deleteUser
}