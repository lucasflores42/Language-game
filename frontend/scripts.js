const simulationButton = document.querySelector("[data-simulation-toggle]");

if (simulationButton) {
  simulationButton.addEventListener("click", () => {
    const isStarting = simulationButton.textContent.trim() === "Start Simulation";

    simulationButton.textContent = isStarting
      ? "Reset Simulation"
      : "Start Simulation";
  });
}
