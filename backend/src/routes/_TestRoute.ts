import express from 'express'
import TestController from '../controllers/_TestController'

const router = express.Router()

router.get('/', TestController.test)

export default router