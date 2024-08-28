document.getElementById('prediction-type').onchange = function(event) {
    let predictionType = event.target.value;

    // Show or hide inputs based on prediction type
    if (predictionType === 'next-day') {
        document.getElementById('multi-day-inputs').style.display = 'none';
    } else if (predictionType === 'multi-day') {
        document.getElementById('multi-day-inputs').style.display = 'block';
    }
};

document.getElementById('prediction-form').onsubmit = function(event) {
    event.preventDefault();

    let stock = document.getElementById('stock').value;
    let predictionType = document.getElementById('prediction-type').value;
    let n_future = document.getElementById('n_future').value;

    let requestData = { stock: stock, prediction_type: predictionType };
    
    if (predictionType === 'multi-day') {
        requestData.n_future = n_future;
    }

    fetch('http://localhost:5000/predict', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestData)
    })
    .then(response => response.json())
    .then(data => {
        let result = document.getElementById('result');
        if (data.Error) {
            result.innerHTML = `<h2>Error:</h2><p>${data.Error}</p>`;
        } else {
            result.innerHTML = `<h2>Predicted Prices:</h2><p>${data.join(', ')}</p>`;
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
};
