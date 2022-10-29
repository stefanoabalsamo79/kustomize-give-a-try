const express = require('express')
const app = express()
const PORT = process.env.PORT || 3000
require('dotenv').config({ path: '/etc/config/.env' })

app.get('/hi', (req, res) => {
  console.log(process.env)
  res.send('howdy, how is going?')
})

app.listen(PORT, () => {
  console.log(`Simple app listening on port ${PORT}`)
})