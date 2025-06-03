import express from 'express'
import AuthenticationController from '../controllers/AuthenticationController'
import { csrfToken } from '../middlewares/csurf'
import { clientType, jwtCheck } from '../middlewares/auth'

const router = express.Router()

router.post('/signin', AuthenticationController.loginUser)

export default router