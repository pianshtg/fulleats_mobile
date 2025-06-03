import express from 'express'
import UserController from '../controllers/RestaurantController'
import { clientType, jwtCheck } from '../middlewares/auth'

const router = express.Router()

router.post('/', clientType, jwtCheck, UserController.createRestaurant)
router.get('/', clientType, jwtCheck, UserController.getRestaurant)
router.get('/all', UserController.getRestaurants)
router.put('/', clientType, jwtCheck, UserController.updateRestaurantMenu)

export default router