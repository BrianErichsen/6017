import * as d3 from 'https://cdn.jsdelivr.net/npm/d3@7/+esm';

// function to load and parse csv doc
async function loadData(file) {
    const data = await d3.csv(file, d3.autoType);
    return data.map(d => ({
        state: d.Province_State,
        confirmed: d.Confirmed,
        deaths: d.Deaths,
        recovered: d.Recovered
    }));
}

function createBarChart(data) {
    const svg = d3.select('#chart');
    const margin = { top: 20, right: 30, bottom: 40, left: 90 };
    const width = parseFloat(svg.style('width')) - margin.left - margin.right;
    const height = parseFloat(svg.style('height')) - margin.top - margin.bottom;

    const x = d3.scaleLinear().domain([0, d3.max(data, d => d.confirmed)]).range([0, width]);
    const y = d3.scaleBand().domain(data.map(d => d.state)).range([0, height]).padding(0.1);

    const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`);

    g.append('g').attr('class', 'axis axis--x').attr('transform', `translate(0,${height})`).call(d3.axisBottom(x));
    
    g.append('g').attr('class', 'axis axis--y').call(d3.axisLeft(y));

    g.selectAll('.bar').data(data).enter().append('rect').attr('class', 'bar').attr('x', 0).attr('y',
        d => y(d.state)).attr('width', d => x(d.confirmed)).attr('height', y.bandwidth());
}

window.onload = async function() {
    const data = await loadData('01-01-2021.csv');
    console.log(data);
    createBarChart(data);
}