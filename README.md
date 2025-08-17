# 128pt_FFT_verilog_ZYNQ
Designed and implemented 128-point FFT hardware module in Verilog, and verified its  functionality on a Xilinx Zynq-7000 FPGA platform

■ 저작권 문제로 직접 작성한 일부 코드만 업로드하였습니다.

## 🚀 프로젝트 개요
본 프로젝트는 디지털 신호 처리의 핵심 연산인 128-Point 고속 푸리에 변환(FFT)을 Verilog HDL을 이용하여 하드웨어로 설계하고, 이를 Xilinx Zynq-7000 FPGA 플랫폼에 구현하여 검증하는 것을 목표로 합니다.

설계된 FFT 하드웨어 모듈은 Vivado에서 AXI-Lite 인터페이스를 갖는 IP 블록으로 패키징되어 Zynq Processing System(PS)에 통합됩니다. ARM 프로세서에서 실행되는 C 코드는 이 IP 블록을 제어하여 FFT 연산을 수행하고, 하드웨어 가속을 통해 고속의 신호 처리가 가능함을 보입니다.

## 🛠️ 개발 환경
하드웨어: Xilinx Zynq-7000 SoC 

설계 툴: Xilinx Vivado 2017.4 , Xilinx SDK 2017.4, tera term

사용 언어: 하드웨어 (RTL): Verilog HDL, 소프트웨어 (제어): C/C++

##  📂 프로젝트 구조 및 흐름
프로젝트는 다음과 같은 단계로 진행되었습니다.

Verilog RTL 설계: 128-Point FFT 연산을 수행하는 하드웨어 모듈을 Verilog로 설계합니다.

IP 패키징: 설계된 Verilog 모듈을 Vivado의 IP Packager를 사용하여 AXI-Lite 인터페이스를 갖는 IP 블록으로 제작합니다.

하드웨어 시스템 통합: Vivado Block Design을 통해 Zynq7 Processing System과 FFT IP를 연결하여 전체 하드웨어 시스템을 구축합니다.

FPGA 구현: 합성(Synthesis), 구현(Implementation), 비트스트림(Bitstream) 생성을 통해 하드웨어 설계를 FPGA에 프로그래밍할 준비를 합니다.

소프트웨어 개발: Vitis(SDK)에서 C 코드를 작성하여 ARM 프로세서가 AXI 버스를 통해 FFT IP를 제어하고 데이터를 주고받도록 합니다.

하드웨어/소프트웨어 검증: 실제 FPGA 보드에서 소프트웨어를 실행하여 FFT 하드웨어 가속기의 기능과 성능을 최종 검증합니다.

## 📝 세부 설계 내용
1. Verilog 기반 FFT 모듈 설계
알고리즘: Radix-2 Decimation-In-Time (DIT) 알고리즘을 기반으로 128-Point FFT를 구현했습니다.

구조: Butterfly 연산 유닛: FFT의 핵심 연산인 Butterfly 연산을 수행하는 모듈을 설계했습니다.

1. Verilog 기반 FFT 모듈 아키텍처
FFT 가속기는 파이프라인(Pipelined) 구조를 기반으로 한 Radix-2 DIT(Decimation-In-Time) 알고리즘을 사용하여 128-Point 연산을 수행합니다. 전체 아키텍처는 데이터의 연속적인 처리를 위해 각 연산 단계가 모듈화되어 있으며, 중앙 컨트롤러에 의해 동기화됩니다.

### axi_slave_FFT_f_ps.v (AXI 탑 모듈)

전체 FFT 코어를 감싸는 최상위 모듈로, Zynq의 PS(Processing System)와 PL(Programmable Logic) 간의 인터페이스 역할을 합니다.

AXI4-Lite 슬레이브 프로토콜을 구현하여, ARM 프로세서가 메모리 맵 주소를 통해 FFT 코어를 제어하고 데이터를 송수신할 수 있도록 합니다.

### controller.v (중앙 제어 유닛)

FFT 연산의 모든 과정을 총괄하는 FSM(Finite State Machine) 기반의 컨트롤러입니다.

128개의 데이터 샘플이 파이프라인을 따라 흐르는 동안, 각 클럭 사이클마다 필요한 제어 신호를 생성하여 모든 stage 모듈에 전달합니다.

sel_bf: 각 스테이지에서 Butterfly 연산을 수행할지 여부를 결정합니다.

sel_w: 각 스테이지의 복소수 곱셈에 필요한 Twiddle Factor를 ROM에서 선택하는 주소 신호입니다.

en_reg_out_bus: 최종 출력 순서를 맞추기 위한 reordering_module의 메모리 뱅크를 제어합니다.

### stage.v (FFT 연산 스테이지)

128-Point FFT는 총 7개의 연산 스테이지로 구성되며, 이 모듈은 각 스테이지의 연산을 담당합니다.

내부적으로 Butterfly 연산, Twiddle Factor 곱셈, 데이터 지연을 위한 모듈들로 구성됩니다.

bf.v (Butterfly 유닛): Radix-2 알고리즘의 핵심 연산인 A+B와 A-B를 수행하는 모듈입니다. 두 개의 복소수 입력을 받아 두 개의 복소수 결과를 출력합니다.

mult.v (복소수 곱셈기): Butterfly 연산을 거친 데이터에 해당하는 Twiddle Factor를 곱하는 모듈입니다.

shift_reg.v (시프트 레지스터): 파이프라인 구조에서 데이터 정렬을 위한 지연(Delay)을 발생시키는 역할을 합니다. Butterfly 연산에 필요한 두 데이터의 도착 시점을 동기화합니다.

### reordering_module.v (출력 재정렬 모듈)

Radix-2 FFT 알고리즘의 특성상 연산 결과는 비트-역순(Bit-Reversed Order)으로 출력됩니다. 이 모듈은 뒤섞인 순서의 데이터를 자연스러운 순서(Natural Order)로 재정렬합니다.

두 개의 memory bank (Ping-Pong Buffer)를 사용하여, 한쪽 bank에는 순서가 섞인 FFT 결과가 계속해서 입력되는 동안 다른 쪽 bank에서는 이미 정렬이 완료된 데이터를 읽어갈 수 있도록 하여 파이프라인이 멈추지 않도록 합니다.

2. AXI-Lite IP 블록 생성
설계된 FFT 모듈을 Zynq의 ARM 프로세서와 연결하기 위해 AXI4-Lite 슬레이브 인터페이스를 추가하여 IP로 패키징했습니다.


4. Zynq 시스템 통합
Vivado의 Block Design 기능을 사용하여 다음과 같이 전체 시스템을 구성했습니다.

<img width="1366" height="691" alt="image" src="https://github.com/user-attachments/assets/dad199c7-fe24-492e-901e-65681ccb9ac8" />


Zynq7 Processing System 추가 및 기본 설정 (DDR, UART 등)

생성한 FFT IP 블록 추가

AXI Interconnect를 통해 Zynq PS의 M_AXI_GP0 포트와 FFT IP의 S_AXI_LITE 포트를 연결

Block Design 검증 후 HDL Wrapper 생성 및 Bitstream 생성



4. C 언어를 이용한 제어 소프트웨어
Vitis(SDK) 환경에서 ARM Cortex-A9 프로세서용 제어 프로그램을 작성했습니다.

주요 기능:

초기화: FFT IP의 메모리 주소를 포인터에 매핑하고 초기 상태를 설정합니다.

데이터 쓰기: C 코드에서 생성한 128개의 입력 샘플 데이터(예: Sine wave)를 AXI 버스를 통해 FFT IP 내부의 입력 RAM에 씁니다.

연산 시작: FFT IP의 Control Register에 'start' 비트를 써서 하드웨어 연산을 시작시킵니다.

완료 대기: Control Register의 'done' 비트를 폴링(Polling)하여 FFT 연산이 완료될 때까지 대기합니다.

결과 읽기: 연산이 완료되면 FFT IP의 출력 RAM에서 128개의 결과 데이터를 읽어와 C 변수에 저장합니다.

결과 출력: 읽어온 FFT 결과값을 UART 터미널을 통해 출력하여 확인합니다.

✅ 검증 및 결과
시뮬레이션: Verilog 테스트벤치를 작성하여 RTL 수준에서 FFT 모듈의 기능적 정확성을 검증했습니다.

FPGA 보드 검증:

생성된 비트스트림을 Zybo Z7-20 보드에 다운로드했습니다.

Vitis에서 작성한 C 코드를 보드의 ARM 프로세서에서 실행했습니다.

입력 데이터로 주입한 신호가 FFT 연산을 통해 주파수 영역으로 올바르게 변환되는 것을 UART 출력으로 확인했습니다. 소프트웨어로 계산한 FFT 결과와 하드웨어 가속기의 결과가 일치함을 통해 기능적 정확성을 최종 검증했습니다.
