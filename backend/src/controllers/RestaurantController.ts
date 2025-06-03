import 'dotenv/config'
import { Request, Response } from "express";
import { pool } from "../database";
import { RowDataPacket } from "mysql2";
import jwt from 'jsonwebtoken'


async function createRestaurant (req: Request, res: Response) {

    const accessToken = req.accessToken
    const newAccessToken = req.newAccessToken
    const metaData = accessToken ? jwt.decode(accessToken!) as jwt.JwtPayload : jwt.decode(newAccessToken!) as jwt.JwtPayload

    try {
        // Retrieve request's parameters
        const {name, location, menu} = req.body

        // Check if user exists
        const [user] = await pool.execute<RowDataPacket[]>('SELECT * FROM user WHERE id = ?', [metaData.user_id])
        if (user.length == 0) {
            res.status(409).json({message: "Failed to find user in the database."})
            return;
        }

        await pool.execute('INSERT INTO restaurant (user_id, name, location, menu, image_url) VALUES (?, ?, ?, ?, NULL)', [metaData.user_id, name, location, menu])

        res.status(201).json({
            message: "Successfully created restaurant!",
            created_restaurant: {
                name,
                location,
                menu
            }
        })
        return;

    } catch (error) {
        console.log(error) // Debug.
        res.status(500).json({message: "Error creating restaurant."})
        return
    }

}

async function getRestaurant (req: Request, res: Response) {
    
    const accessToken = req.accessToken
    const newAccessToken = req.newAccessToken
    const metaData = accessToken ? jwt.decode(accessToken!) as jwt.JwtPayload : jwt.decode(newAccessToken!) as jwt.JwtPayload

    try {
        const [restaurant] = await pool.execute<RowDataPacket[]>('SELECT * FROM restaurant WHERE user_id = ?', [metaData.user_id])
        if (restaurant.length > 0) {
            res.status(200).json({
                message: `Successfully retrieved restaurant for ${metaData.user_id}`,
                restaurant: restaurant[0],
            })
            return
        } else {
            res.status(404).json({message: "No restaurant found for user."})
            return
        }
    } catch (error) {
        res.status(500).json({message: "Error getting restaurant."})
        return
    }
}

async function getRestaurants (req: Request, res: Response) {
    try {
        const [restaurants] = await pool.execute<RowDataPacket[]>('SELECT * FROM restaurant')
        if (restaurants.length > 0) {
            res.status(200).json({
                message: "Successfully retrieved all restaurants.",
                restaurants,
            })
            return
        } else {
            res.status(409).json({message: "No restaurants found."})
            return
        }
    } catch (error) {
        res.status(500).json({message: "Error getting restaurants."})
        return
    }
}

async function updateRestaurantMenu (req: Request, res: Response) {

    const accessToken = req.accessToken
    const newAccessToken = req.newAccessToken
    const metaData = accessToken ? jwt.decode(accessToken!) as jwt.JwtPayload : jwt.decode(newAccessToken!) as jwt.JwtPayload

    try {
        // Retrieve request's parameter
        const {menu} = req.body

        // Check if user and user's restaurant exists
        const [user] = await pool.execute<RowDataPacket[]>('SELECT * FROM user WHERE id = ?', [metaData.user_id])
        if (user.length == 0) {
            res.status(409).json({message: "Failed to find user in the database."})
            return;
        }
        const [restaurant] = await pool.execute<RowDataPacket[]>('SELECT * FROM restaurant WHERE user_id = ?', [metaData.user_id])
        if (restaurant.length == 0) {
            res.status(409).json({message: "Failed to find restaurant in the database."})
            return;
        }

        await pool.execute('UPDATE restaurant SET menu = ?', [menu])
        console.log("Success udpate!")

        res.status(200).json({
            message: "Successfully updated restaurant's menu.",
            menu,
            newAccessToken
        })
        return;

    } catch (error) {
        console.log(error) // Debug.
        res.status(500).json({message: "Error updating restaurant's menu."})
        return
    }
}

export default {
    createRestaurant,
    getRestaurant,
    getRestaurants,
    updateRestaurantMenu
}