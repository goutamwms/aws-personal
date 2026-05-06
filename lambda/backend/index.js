const express = require('express');
const serverless = require('serverless-http');
const cors = require('cors');
const { S3Client, PutObjectCommand, GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const app = express();
app.use(cors());
app.use(express.json());

const s3Client = new S3Client({ region: "us-east-1" });
const BUCKET_NAME = "your-s3-repo"; // cite: 1

// Endpoint to get a signed URL for uploading
app.post('/get-upload-url', async (req, res) => {
    const { fileName, fileType } = req.body;
    const command = new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: `uploads/${fileName}`,
        ContentType: fileType
    });

    console.log("Generating URL for:", fileName, "in bucket:", BUCKET_NAME);

    try {
        const url = await getSignedUrl(s3Client, command, { expiresIn: 300 });
        res.json({ uploadUrl: url, key: `uploads/${fileName}` });
    } catch (err) {
        res.status(500).json({ error: "Failed to generate upload URL" });
    }
});

// Endpoint to get a signed URL for viewing
app.get('/view/:key', async (req, res) => {
    const command = new GetObjectCommand({
        Bucket: BUCKET_NAME,
        Key: req.params.key
    });

    try {
        const url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
        res.json({ viewUrl: url });
    } catch (err) {
        res.status(500).json({ error: "Failed to generate view URL" });
    }
});

app.get('/health', async (req, res) => {
    res.status(200).json({ message: "Healthy" });
});

module.exports.handler = serverless(app); // cite: 1