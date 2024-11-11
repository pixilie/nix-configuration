{config, pkgs, ...}:

{
  programs.waybar = { 
    enable = true;
    settings = {
      "mainBar" = {
        "layer" = "top";
	      "position" = "bottom";
	      "id" = "bar-0";
	      "ipc" = true;
	      "mode" = "invisible";

	      "modules-left" = [ "sway/mode" "sway/workspaces" ];

	      "modules-right" = [
	      	"custom/arrow9"
	      	"pulseaudio"
	      	"custom/arrow8"
	      	"network"
	      	"custom/arrow7"
	      	"memory"
	      	"custom/arrow6"
	      	"cpu"
	      	"custom/arrow5"
	      	"temperature"
	      	"custom/arrow4"
	      	"battery"
	      	"custom/arrow3"
	      	"disk"
	      	"custom/arrow2"
	      	"clock#date"
	      	"custom/arrow1"
	      	"clock#time"
	      ];

	      # Modules
	      "battery" = {
	      	"interval" = 20;
	      	"states" = { "warning" = 30; "critical" = 10; };
	      	"format" = "{icon}  {capacity}%";
	      	"format-charging" = " {capacity}%";
	      	"format-charging-full" = " {capacity}%";
	      	"format-full" = "{icon} {capacity}%";
	      	"format-icons" = [ "" ""	""	""	""	];
	      	"tooltip" = false;
	      };

	      "clock#time" = {
	      	"interval" = 10;
	      	"format" = "{:%H:%M}";
	      	"tooltip" = false;
	      };

	      "clock#date" = {
	      	"interval" = 60;
	      	"format" = "{:%e %b %Y}";
	      	"tooltip" = false;
	      	"tooltip-format" = "{:%e %B %Y}";
	      };

	      "cpu" = {
	      	"interval" = 5;
	      	"tooltip" = false;
	      	"format" = "  {usage}%";
	      	"format-alt" = "  {load}";
	      	"states" = { "warning" = 70;	"critical" = 90; };
	      };

	      "disk" = {
	      	"unit" = "GB";
	      	"format" = "   {specific_free:0.2f}GB";
	      	"interval" = 0;
	      	"path" = "/";
	      };
	      
	      "memory" = {
	      	"interval" = 10;
	      	"format" = " {used:0.1f}G/{total:0.1f}G";
	      	"states" = { "warning" = 70; "critical" = 90; };
	      	"tooltip" = false;
	      };

	      "network" = {
	      	"interval" = 10;
	      	"format-wifi" = "   {essid} ({signalStrength}%)";
	      	"format-ethernet" = "  {ifname}";
	      	"format-disconnected" = "No connection";
	      	"format-alt" = "  {ipaddr}/{cidr}";
	      	"tooltip" = false;
	      };

	      "sway/mode" = {
	      	"format" = "{}";
	      	"tooltip" = false;
	      };

	      "sway/workspaces" = {
	      	"disable-scroll-wraparound" = true;
	      	"smooth-scrolling-threshold" = 4;
	      	"enable-bar-scroll" = true;
	      	"format" = "{name}";
	      };

	      "pulseaudio" = {
	      	"format" = "{icon}  {volume}%";
	      	"format-bluetooth" = "{icon}  {volume}%";
	      	"format-muted" = "";
	      	"format-icons" = {
	      		"headphone" = "";
	      		"hands-free" = "";
	      		"headset" = "";
	      		"phone" = "";
	      		"portable" = "";
	      		"car" = "";
	      		"default" = ["" ""];
	      	};
	      	"scroll-step" = 1;
	      	"tooltip" = false;
	      };

	      "temperature" = {
	      	"critical-threshold" = 90;
	      	"interval" = 10;
	      	"format" = "{icon} {temperatureC}°";
	      	"format-icons" = [	""	""	""	""	""	];
	      	"tooltip" = false;
	      };

	      "custom/arrow1" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };

	      "custom/arrow2" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };

	      "custom/arrow3" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };

	      "custom/arrow4" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };

	      "custom/arrow5" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };

	      "custom/arrow6" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };

	      "custom/arrow7" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };

	      "custom/arrow8" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };

	      "custom/arrow9" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };
          
	      "custom/arrow10" = {
	      	"format" = "";
	      	"tooltip" = false;
	      };
      };
    };

    style = ''
      /* Keyframes */
      
      @keyframes blink-critical {
      	to {
      		/*color: @white;*/
      		background-color: @critical;
      	}
      }
      
      
      /* Styles */
      
      /* Colors (gruvbox) */
      @define-color black	#282828;
      @define-color red	#cc241d;
      @define-color green	#98971a;
      @define-color yellow	#d79921;
      @define-color blue	#458588;
      @define-color purple	#b16286;
      @define-color aqua	#689d6a;
      @define-color gray	#a89984;
      @define-color brgray	#928374;
      @define-color brred	#fb4934;
      @define-color brgreen	#b8bb26;
      @define-color bryellow	#fabd2f;
      @define-color brblue	#83a598;
      @define-color brpurple	#d3869b;
      @define-color braqua	#8ec07c;
      @define-color white	#ebdbb2;
      @define-color bg2	#504945;
      
      @define-color warning 	@bryellow;
      @define-color critical	@red;
      @define-color mode	@black;
      @define-color unfocused	@bg2;
      @define-color focused	@braqua;
      @define-color inactive	@purple;
      @define-color sound	@brpurple;
      @define-color network	@purple;
      @define-color memory	@braqua;
      @define-color cpu	@green;
      @define-color temp	@brgreen;
      @define-color disk	@bryellow;
      @define-color battery	@aqua;
      @define-color date	@black;
      @define-color time	@white;
      
      /* Reset all styles */
      * {
      	border: none;
      	border-radius: 0;
      	min-height: 0;
      	margin: 0;
      	padding: 0;
      	box-shadow: none;
      	text-shadow: none;
      	-gtk-icon-shadow: none;
      }
      
      /* The whole bar */
      #waybar {
      	background: #000000;
      	color: @white;
      	font-family: JetBrains Mono;
      	font-size: 10pt;
      	font-weight: bold;
      }
      
      /* Each module */
      #battery,
      #clock,
      #cpu,
      #memory,
      #mode,
      #network,
      #pulseaudio,
      #temperature,
      #tray,
      #backlight,
      #idle_inhibitor,
      #disk,
      #user,
      #mpris {
      	padding-left: 8pt;
      	padding-right: 8pt;
      }
      
      /* Each critical module */
      #mode,
      #memory.critical,
      #cpu.critical,
      #temperature.critical,
      #battery.critical.discharging {
      	animation-timing-function: linear;
      	animation-iteration-count: infinite;
      	animation-direction: alternate;
      	animation-name: blink-critical;
      	animation-duration: 1s;
      }
      
      /* Each warning */
      #network.disconnected,
      #memory.warning,
      #cpu.warning,
      #temperature.warning,
      #battery.warning.discharging {
      	color: @warning;
      }
      
      /* And now modules themselves in their respective order */
      
      /* Current sway mode (resize etc) */
      #mode {
      	color: @white;
      	background: @mode;
      }
      
      /* Workspaces stuff */
      #workspaces button {
      	/*font-weight: bold;*/
      	padding-left: 3pt;
      	padding-right: 3pt;
      	color: @white;
      	background: @unfocused;
      }
      
      /* Inactive (on unfocused output) */
      #workspaces button.visible {
      	color: @white;
      	background: @inactive;
      }
      
      /* Active (on focused output) */
      #workspaces button.focused {
      	color: @black;
      	background: @focused;
      }
      
      /* Contains an urgent window */
      #workspaces button.urgent {
      	color: @black;
      	background: @warning;
      }
      
      /* Style when cursor is on the button */
      #workspaces button:hover {
      	background: @black;
      	color: @white;
      }
      
      #window {
      	margin-right: 35pt;
      	margin-left: 35pt;
      }
      
      #pulseaudio {
      	background: @sound;
      	color: @black;
      }
      
      #network {
      	background: @network;
      	color: @white;
      }
      
      #memory {
      	background: @memory;
      	color: @black;
      }
      
      #cpu {
      	background: @cpu;
      	color: @white;
      }
      
      #temperature {
      	background: @temp;
      	color: @black;
      }
      
      #disk {
      	background: @disk;
      	color: @black;
      }
      
      #battery {
      	background: @battery;
      	color: @white;
      }
      
      #tray {
      	background: @date;
      }
      
      #clock.date {
      	background: @date;
      	color: @white;
      }
      
      #clock.time {
      	background: @time;
      	color: @black;
      }
      
      #custom-arrow1 {
      	font-size: 11pt;
      	color: @time;
      	background: @date;
      }
      
      #custom-arrow2 {
      	font-size: 11pt;
      	color: @date;
      	background: @disk;
      }
      
      #custom-arrow3 {
      	font-size: 11pt;
      	color: @disk;
      	background: @battery;
      }
      
      #custom-arrow4 {
      	font-size: 11pt;
      	color: @battery;
      	background: @temp;
      }
      
      #custom-arrow5 {
      	font-size: 11pt;
      	color: @temp;
      	background: @cpu;
      }
      
      #custom-arrow6 {
      	font-size: 11pt;
      	color: @cpu;
      	background: @memory;
      }
      
      #custom-arrow7 {
      	font-size: 11pt;
      	color: @memory;
      	background: @network;
      }
      
      #custom-arrow8 {
      	font-size: 11pt;
      	color: @network;
      	background: @sound;
      }
      
      #custom-arrow9 {
      	font-size: 11pt;
      	color: @sound;
      	background: transparent;
      }
      
      #custom-arrow10 {
      	font-size: 11pt;
      	color: @unfocused;
      	background: transparent;
      }
  '';
  };    
}
