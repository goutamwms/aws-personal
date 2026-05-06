import { useState } from 'react';
import axios from 'axios';

const API_BASE = "https://your-lambda-url.lambda-url.ap-south-1.on.aws"; // Your CloudFront/Lambda URL

function App() {
  const [file, setFile] = useState<File | null>(null);
  const [viewUrl, setViewUrl] = useState("");

  const handleUpload = async () => {
    if (!file) return;

    // 1. Get Signed URL from Backend
    const { data } = await axios.post(`${API_BASE}/get-upload-url`, {
      fileName: file.name,
      fileType: file.type
    });

    // 2. Upload directly to S3
    await axios.put(data.uploadUrl, file, {
      headers: { "Content-Type": file.type }
    });

    alert("Upload Successful!");
    
    // 3. Get view URL for the uploaded file
    // const viewRes = await axios.get(`${API_BASE}/view/${data.key}`);

    const encodedKey = encodeURIComponent(data.key);
    const viewRes = await axios.get(`${API_BASE}/view/${encodedKey}`);

    console.log("View URL:", viewRes.data.viewUrl);
    
    setViewUrl(viewRes.data.viewUrl);
  };

  return (
    <div style={{ padding: '20px', textAlign: 'center' }}>
      <h1>S3 Secure Upload</h1>
      <input type="file" onChange={(e) => setFile(e.target.files?.[0] || null)} />
      <button onClick={handleUpload}>Upload to AWS</button>

      {viewUrl && (
        <div style={{ marginTop: '20px' }}>
          <h3>Preview:</h3>
          <img src={viewUrl} alt="S3 Content" style={{ maxWidth: '300px' }} />
        </div>
      )}
    </div>
  );
}

export default App;