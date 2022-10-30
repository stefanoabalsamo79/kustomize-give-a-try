const express = require('express')
const app = express()
const PORT = process.env.PORT || 3000

app.get('/hi', (req, res) => {
  res.send('howdy, how is going?')
})

app.listen(PORT, () => {
  console.log(`Simple app listening on port ${PORT}`)
})