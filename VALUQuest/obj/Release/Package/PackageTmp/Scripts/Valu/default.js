function formatDateForInput(dateString) {
    // Create a Date object from the dateString
    var dateObj = new Date(dateString);

    // Get the year, month, and day components from the Date object
    var year = dateObj.getFullYear();
    var month = String(dateObj.getMonth() + 1).padStart(2, '0'); // Add leading zero if month < 10
    var day = String(dateObj.getDate()).padStart(2, '0'); // Add leading zero if day < 10

    // Construct the formatted date string (YYYY-MM-DD)
    var formattedDate = `${year}-${month}-${day}`;

    return formattedDate;
}

// Function to show overlay and spinner
function showOverlay() {
    $('#overlay').fadeIn(); // Show overlay
    document.getElementById('overlay').style.display = 'flex';
}

// Function to hide overlay and spinner
function hideOverlay() {
    $('#overlay').fadeOut(); // Hide overlay
    document.getElementById('overlay').style.display = 'none';
}

