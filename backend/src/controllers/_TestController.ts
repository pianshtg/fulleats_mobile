import 'dotenv/config'
import { pool } from "../database";
import { RowDataPacket } from "mysql2";
import { Request, Response } from 'express';
import bcrypt from 'bcrypt'

async function test (req: Request, res: Response) {
    try {
        const accessToken = req.accessToken
        const {email, new_password} = req.body
        const new_hashed_password_arr: string[] = await Promise.all(
            email.map( async (x: string, index: number ) => {
                let new_hashed_password = await bcrypt.hash(new_password[index], 10)
                await pool.execute<RowDataPacket[]>('UPDATE users_hashed_password SET hashed_password = ? WHERE user_id = (SELECT id FROM users WHERE email = ?)', [new_hashed_password, x])
                return new_hashed_password
        })
        )
        // const [result] = await pool.execute<RowDataPacket[]>('UPDATE users_hashed_password SET hashed_password = ? WHERE user_id = (SELECT id FROM users WHERE email = ?)', [new_hashed_password, email])
        res.status(200).json({
            message: `Successfully changed password for: [${email}]`,
            new_hashed_password_arr,
            accessToken
        })
        return
    } catch (error) {
        console.error(error) // Debug.
        res.status(500).json({message: "Error testing."})
        return
    }
}

export default {
    test
}