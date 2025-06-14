import "dotenv/config";
import express, { Request, Response } from 'express'
import {v2 as cloudinary} from 'cloudinary'
import authenticationRoute from './routes/AuthenticationRoute'
import testRoute from './routes/_TestRoute'
import userRoute from './routes/UserRoute'
import restaurantRoute from './routes/RestaurantRoute'
import { clientType, jwtCheck } from './middlewares/auth'
import { testConnection } from './database'

const app = express()

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
})

// Middlewares
app.use(express.json())

// Health Check
app.get("/", async (req: Request, res: Response) => {
    res.json({message: "Hi!"})
})

// Test Route
app.use("/api/test", testRoute)

// Routes
app.use("/api/auth", authenticationRoute)
app.use("/api/user", clientType, jwtCheck, userRoute)
app.use("/api/restaurant", restaurantRoute)

// Start Server
async function startServer() {
    try {
        await testConnection()
        app.listen(3030, () => {
            console.log("----------------------------------\nServer started on localhost:3030..\n----------------------------------")
        })
    } catch (error) {
        console.error("Failed to connect database. Server is failed to start: ", error)
    }
}

startServer()