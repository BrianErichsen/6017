import * as d3 from 'https://cdn.jsdelivr.net/npm/d3@7/+esm';
import { feature, mesh } from 'https://cdn.jsdelivr.net/npm/topojson@3/+esm';

const width = 960;
const height = 600;

// Function to load and parse CSV
async function loadData(file) {
    // Load CSV data using D3 and auto-detect data types
    const data = await d3.csv(file, d3.autoType);
    console.log("Loaded Data:", data);
    // Return an array of objects with selected fields
    return data.map(d => ({
        state: d.Province_State,
        confirmed: d.Confirmed,
        deaths: d.Deaths,
        recovered: d.Recovered
    }));
}

async function createMap(us) {
    // Load the COVID data
    const data = await loadData('01-01-2021.csv');

    // Define a color scale based on confirmed cases
    const color = d3.scaleSequential()
        .domain([0, d3.max(data, d => d.confirmed)])
        .interpolator(d3.interpolateReds);

    // Define the zoom behavior
    const zoom = d3.zoom()
        .scaleExtent([1, 8])
        .on("zoom", zoomed);

    // Create the SVG container
    const svg = d3.select("#map")
        .attr("viewBox", [0, 0, width, height])
        .attr("width", width)
        .attr("height", height)
        .attr("style", "max-width: 100%; height: auto;")
        .on("click", reset);

    // Define the projection and path generator
    const projection = d3.geoAlbersUsa()
        .scale(1300)
        .translate([width / 2, height / 2]);

    const path = d3.geoPath().projection(projection);

    // Create a group for the map
    const g = svg.append("g");

    // Create and style the state paths
    const states = g.append("g")
        .attr("fill", "#444")
        .attr("cursor", "pointer")
        .selectAll("path")
        .data(feature(us, us.objects.states).features)
        .join("path")
        .on("click", clicked)
        .attr("d", path)
        .attr("fill", d => {
            const stateData = data.find(state => state.state === d.properties.name);
            return stateData ? color(stateData.confirmed) : '#ccc';
        });

    // Add state names as tooltips
    states.append("title")
        .text(d => d.properties.name);

    // Add state borders
    g.append("path")
        .attr("fill", "none")
        .attr("stroke", "white")
        .attr("stroke-linejoin", "round")
        .attr("d", path(mesh(us, us.objects.states, (a, b) => a !== b)));

    // Apply the zoom behavior to the SVG
    svg.call(zoom);

    // Reset the zoom and map fill
    function reset() {
        states.transition().style("fill", null);
        svg.transition().duration(750).call(
            zoom.transform,
            d3.zoomIdentity,
            d3.zoomTransform(svg.node()).invert([width / 2, height / 2])
        );
    }

    // Handle state click events for zooming
    function clicked(event, d) {
        const [[x0, y0], [x1, y1]] = path.bounds(d);
        event.stopPropagation();
        states.transition().style("fill", null);
        d3.select(this).transition().style("fill", "red");
        svg.transition().duration(750).call(
            zoom.transform,
            d3.zoomIdentity
              .translate(width / 2, height / 2)
              .scale(Math.min(8, 0.9 / Math.max((x1 - x0) / width, (y1 - y0) / height)))
              .translate(-(x0 + x1) / 2, -(y0 + y1) / 2),
            d3.pointer(event, svg.node())
        );
    }

    // Handle zoom events
    function zoomed(event) {
        const { transform } = event;
        g.attr("transform", transform);
        g.attr("stroke-width", 1 / transform.k);
    }

    // Initial center and scale for the map
    const initialScale = 1.5;
    const initialTranslate = [width / 2, height / 2];
    svg.call(zoom.transform, d3.zoomIdentity.translate(initialTranslate[0], initialTranslate[1]).scale(initialScale));
}

window.onload = async function() {
    // Load US map data and create the map
    const us = await d3.json("https://cdn.jsdelivr.net/npm/us-atlas@3/states-10m.json");
    console.log("Loaded US Map Data:", us);
    createMap(us);
};
