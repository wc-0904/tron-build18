module gpio_test(
    input logic [3:0] pd_port,
    output logic [3:0] led
);

    assign led = pd_port;

endmodule: gpio_test