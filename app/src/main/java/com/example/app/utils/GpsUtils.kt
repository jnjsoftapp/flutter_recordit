class GpsUtils {
    fun getLocationFromMedia(filePath: String): Location? {
        val exif = ExifInterface(filePath)
        val latLong = FloatArray(2)
        
        if (exif.getLatLong(latLong)) {
            return Location("").apply {
                latitude = latLong[0].toDouble()
                longitude = latLong[1].toDouble()
            }
        }
        return null
    }
    
    fun updateGpsInfo(filePath: String, latitude: Double, longitude: Double) {
        val exif = ExifInterface(filePath)
        exif.setLatLong(latitude, longitude)
        exif.saveAttributes()
    }
} 