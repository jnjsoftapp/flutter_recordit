class FileUploader {
    private val client = OkHttpClient()
    
    fun uploadFile(filePath: String, serverUrl: String) {
        val file = File(filePath)
        val requestBody = MultipartBody.Builder()
            .setType(MultipartBody.FORM)
            .addFormDataPart(
                "file",
                file.name,
                file.asRequestBody("multipart/form-data".toMediaType())
            )
            .build()

        val request = Request.Builder()
            .url(serverUrl)
            .post(requestBody)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                // 실패 처리
            }

            override fun onResponse(call: Call, response: Response) {
                // 성공 처리
            }
        })
    }
} 