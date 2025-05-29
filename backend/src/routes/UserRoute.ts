import express from 'express'
import UserController from '../controllers/UserController'

const router = express.Router()

router.post('/', UserController.createUser)
router.get('/', UserController.getUser)
router.get('/all', UserController.getUsers)
router.patch('/', UserController.updateUser)
router.post('/soft-delete', UserController.deleteUser)

export default router