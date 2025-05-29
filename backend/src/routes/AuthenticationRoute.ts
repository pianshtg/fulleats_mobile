import express from 'express'
import AuthenticationController from '../controllers/AuthenticationController'
import { csrfToken } from '../middlewares/csurf'
import { clientType, jwtCheck } from '../middlewares/auth'

const router = express.Router()

router.post('/', clientType, AuthenticationController.authenticateUser)
router.post('/signin', AuthenticationController.loginUser)
router.post('/logout', clientType, jwtCheck, AuthenticationController.logoutUser)
router.post('/pass', clientType, jwtCheck, AuthenticationController.changePassword)
router.get('/verify-email', AuthenticationController.verifyEmail)
router.get('/csrf-token', csrfToken)

export default router