module gpio_test(
    input logic [7:0] pd_port,
    output logic [7:0] led
);

    assign led = pd_port;

endmodule: gpio_test