# Generate and run software for the examples

Run these steps from the example project directory in a VS Code terminal.

1. Open the Nios V Command Shell:

   ```powershell
   & 'C:\altera_lite\25.1std\niosv\bin\niosv-shell.exe' --powershell
   ```

2. Generate the BSP:

   ```powershell
   niosv-bsp -c -t=hal --sopcinfo=niosv.sopcinfo software/bsp/settings.bsp
   ```

3. Create the software application:

   ```powershell
   niosv-app -a=software/app -b=software/bsp -s="software/app/hello.c"
   ```

4. Generate the Makefile:

   ```powershell
   cmake -S . -B build -G "Unix Makefiles"
   ```

5. Compile the application:

   ```powershell
   cmake --build build
   ```

6. Open a UART-over-JTAG terminal:

   ```powershell
   juart-terminal
   ```

7. Download the generated application:

   ```powershell
   niosv-download -g ./build/app.elf
   ```
