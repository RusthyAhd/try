const dotenv = require('dotenv')
dotenv.config();

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const CustomResponse = require('./utils/custom.response');

// Import routes
const OwnerRouter = require('./routes/OwnerRoutes'); // Shop Owner routes
 // Service Provider routes


const ToolRoute = require('./routes/ToolRoutes');
const ToolOrderRoute = require('./routes/ToolOrderRoutes');

//const {json, urlencoded} = require("body-parser");
const bodyParser = require('body-parser');
const userRoutes = require('./routes/newroute');


// Initialize the express app
const app = express();

// Enable CORS for all routes
app.use(cors()); // Apply CORS middleware

// app.use(json());
// app.use(urlencoded({ extended: true }));

// Increase the JSON payload limit to 10 MB
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));

// Enable Mongoose debug mode to log all queries
mongoose.set('debug', true);

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('MongoDB Successfully Connected with TapOn-DB'))
    .catch(error => {
        console.error('MongoDB Connection Error:', error.message);
    });



app.get('/test', function (req, res, next) {

    res.status(200).send(
        new CustomResponse(
            200,
            'Harii...'
        )
    );

})



// Use middleware for parsing JSON (built-in Express middleware)
app.use(express.json());

// Define the routes for shop owner and service provider registration
app.use('/api/v1/shop', OwnerRouter);  // Shop owner routes are under /shopowner
// Service provider routes are under /serviceprovider


app.use('/api/v1/tool',ToolRoute)
app.use('/api/v1/to',ToolOrderRoute)

app.use('/api/v1/profile',userRoutes);
app.use('/api/v1', require('./routes/ToolOrderRoutes'));
// this should always be the end of the routs
//this is for unhandled routes
app.all('*',(
    req,
    res,
    next
) => {
    res.status(404).send(
        new CustomResponse(
            404,
            `Can't find ${req.originalUrl} path on the server`
        )
    )
})


// Define a simple route for the home page
app.get('/', (req, res) => {
    res.send("Hello TapOn Guys");
});

// Start the server and listen on port 3000
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server is listening on http://localhost:${port}`);
});
