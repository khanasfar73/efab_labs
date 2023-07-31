


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////	combinational adder verification   	////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	

`include "uvm_macros.svh"					// will give an access to uvm macros
 import uvm_pkg::*;							// will give an access to uvm pkg


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//---------------- transaction class -------------------

// keep track of all i/p's and o/p's of the RTL(DUT) except global signals i.e clk we r dealing with them in hvl_top.



class seq_itm extends uvm_sequence_item;

	rand logic [3:0] a;									// class properties 
	rand logic [3:0] b;									// i/p port's qualified with rand bcz we want to take help of pesudo random
														
	     logic [4:0] y;									// o/p port's keept as it is. 
																	

	`uvm_object_utils_begin(seq_itm)					// factory registration and field macros
		`uvm_field_int(a,UVM_DEFAULT + UVM_DEC)			// UVM_DEFAULT or UVM_ALL_ON flag
		`uvm_field_int(b,UVM_DEFAULT + UVM_DEC)		
		`uvm_field_int(y,UVM_DEFAULT + UVM_DEC)		 
	`uvm_object_utils_end							
	

	function new(input string name = "seq_itm");		// object class in UBCH hence one argument
		super.new(name);
	endfunction: new

endclass: seq_itm



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// ------------------- sequence class  ----------------------



class sequence1 extends uvm_sequence #(seq_itm);

	`uvm_object_utils(sequence1)				

	function new(input string name = "sequence1");		
		super.new(name);								
	endfunction: new		

			
	virtual task body();					
											
		req = seq_itm::type_id::create("req");		
								
      repeat(10) begin: B1				
							
			start_item(req);			
			void'(req.randomize());			
			`uvm_info(get_type_name(),"Data send to driver",UVM_NONE)	
			req.print();							
			finish_item(req);			
		
	  end: B1					

	endtask: body						
	

endclass: sequence1





// ------------------- sequencer class ---------------------


class sequencer extends uvm_sequencer #(seq_itm);

	`uvm_component_utils(sequencer)					// FR macrow

	 function new(input string name = "sequencer", uvm_component parent);	
		super.new(name,parent);						
	 endfunction: new

endclass: sequencer




// // ------------------- callback class ---------------------



class drv_callback extends uvm_callback;
  
  
  `uvm_object_utils(drv_callback)
  
  
  function new(input string name = "drv_callback");
    super.new(name);
  endfunction: new
  
  virtual task pre_send();			// two empty methods , virtaul bcz in future we can define child for it and override them
  endtask: pre_send
  
  
  virtual task post_send();
  endtask: post_send
  
  
endclass: drv_callback


// // ------------------- extended callback class ---------------------




class drv_callback1 extends drv_callback;
  
  `uvm_object_utils(drv_callback1)
  
  
  function new(input string name = "drv_callback1");
    super.new(name);
  endfunction: new
  
  virtual task pre_send();	
    `uvm_info(get_type_name(), "pre_send in side of drv_callback1", UVM_NONE)
  endtask: pre_send
  
  
  virtual task post_send();
    `uvm_info(get_type_name(), "post_send in side of drv_callback1", UVM_NONE)
  endtask: post_send
  
  
endclass: drv_callback1 



// ------------------- driver class ---------------------



class driver extends uvm_driver #(seq_itm);


	virtual adder_if vif;						
									

	`uvm_component_utils(driver)					// factory registration
  
 	`uvm_register_cb(driver, drv_callback);			// register drvier with callback class 

	function new(input string name = "driver", uvm_component parent = null);// component hence two arguments
		super.new(name,parent);					
	endfunction: new 

	
// build_phase:- responsible for building all lower level components
//		 executes in top down manner.	


	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		req = seq_itm::type_id::create("req");							// req is an inbuild object of xtn type
		if(!uvm_config_db #(virtual adder_if)::get(this,"","virtual_intf",vif))	// hence no need to declare it
		`uvm_fatal(get_type_name(),"Unable to get interface vif")
	endfunction: build_phase


// run_phase:- task bcz contain delay:- driver drive stimuls to DUT and monitor capture information from DUT based on DUT protocol.
//	       executes in parallel and all pre-post run phases.



	virtual task run_phase(uvm_phase phase);
	
		forever begin: B1				// receive multiple  sequences inside drv do not proceed with raise & drop objection 
          
         
			`uvm_do_callbacks(driver, drv_callback, pre_send())		// adding callback hooks						
			seq_item_port.get_next_item(req);	
          
        
								
				vif.a <= req.a;			// drive random stimuls to DUT through vif.
				vif.b <= req.b;			// use non-blocking assignment for driving

				`uvm_info(get_type_name(),"data send  to DUT",UVM_NONE)
				req.print();			
				#5;						// any delay
          
			seq_item_port.item_done();	
          
          `uvm_do_callbacks(driver, drv_callback, post_send())	 // adding callback hooks
          
       
																
		end: B1	

	endtask: run_phase
	
endclass: driver





// ------------------- monitor class ---------------------



class monitor extends uvm_monitor;


	seq_itm trans;						

	virtual adder_if vif;							
													
	uvm_analysis_port #(seq_itm) ap;				// uvm_analysis_port, one to many kind of scenario			
													// dimond shape and parameterize with type of xtn 

	`uvm_component_utils(monitor)					// factory registration

	function new(input string name = "monitor", uvm_component parent = null);// component hence two arguments
		super.new(name,parent);						
		ap = new("ap",this);						// memory allocation for ap, here or in build_phase anything is fine
	endfunction: new 

	
// build_phase:- responsible for building all lower level components
//		 executes in top down manner.	


	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		trans = seq_itm::type_id::create("trans",this);
		if(!uvm_config_db #(virtual adder_if)::get(this,"","virtual_intf",vif))
		`uvm_fatal(get_type_name(),"Unable to get interface vif")	// default verbosity is UVM_MEDIUM
	endfunction: build_phase


// run_phase:- task bcz contain delay:- driver drive stimuls to DUT and monitor capture information from DUT based on DUT protocol.
//	       executes in parallel and all pre-post run phases.


	virtual task run_phase(uvm_phase phase);
	
		forever begin: B1	
		
			#5;							// same delay as mention in drv

			trans.a  = vif.a;			// capturing information from DUT through vif(virtual interface)
			trans.b  = vif.b;			// either blk or non-blk assignments
			trans.y  = vif.y;			

			`uvm_info(get_type_name(),"Send data to SB",UVM_NONE)
			trans.print();				// just print transctions
          
			ap.write(trans);			// collecting data into ap		
										// ap has write method which is non-blocking in nature							
		end: B1	

	endtask: run_phase


endclass: monitor




// ------------------- agent_config class  ----------------------



class agent_config extends uvm_object;

	
	uvm_active_passive_enum  is_active = UVM_ACTIVE;	
  
	`uvm_object_utils(agent_config)				// factory registration
												// by default its an UVM_ACTIVE for passive agent UVM_PASSIVE

	function new(input string name = "agent_config");	// default constructor expecting only one argument
		super.new(name);
	endfunction: new							// AUVM_ACTIVE/PASSIVE are enum type

endclass: agent_config




// ------------------- agent class  ---------------------- 


class agent extends uvm_agent;

	
	agent_config		a_cfg;					// instance/handler for agent config drv,mon,seqr classes
	driver 				drv_h;					
	sequencer 		 	seqr_h;
	monitor 			mon_h;					

	`uvm_component_utils(agent)					// factory regestration

	function new(input string name = "agent", uvm_component parent = null);// component class in UBCH hence two arguments
		super.new(name,parent);
	endfunction: new


// build_phase:- responsible for building all lower level components
//		 executes in top down manner.	


	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);						// monitor is there by default bcz its common for both active or passive agent	
	
		mon_h = monitor::type_id::create("mon_h",this);	// using factory's create method creating all lower level components
		a_cfg = agent_config::type_id::create("a_cfg");

		if(!uvm_config_db #(agent_config)::get(this,"","agent_configuration",a_cfg))
		`uvm_fatal(get_type_name(),"Can't get() a_cfg fom uvm_config_db, Have you set it?")

		if(a_cfg.is_active == UVM_ACTIVE) begin: B1		
			drv_h  = driver::type_id::create("drv_h",this);	// get_is_active() is of bit type
			seqr_h = sequencer::type_id::create("seqr_h",this);
		end: B1

	endfunction: build_phase


// connect_phase:- responsible for establishing connection between all created components by  port-export
//		   executes in buttom up manner.


	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		if(a_cfg.is_active == UVM_ACTIVE) begin: B1
			drv_h.seq_item_port.connect(seqr_h.seq_item_export);	// connection between drvr and seqr 
		end: B1

	endfunction: connect_phase									// connection start with drv bcz it's an initiator
																// driver class is initiator hence have a port(seq_item_port)
																// monitor class is consumer hence have a export(seq_item_export)
endclass: agent													// driver has in built TLM port called seq_item_port
																// and sequencer has built TLM port called seq_item_export




// ------------------- scoreboard class ---------------------


// receive transactions from monitor and perform comparasion with golden data.
// implementation details i.e write method(function) of analysis port.


class scoreboard extends uvm_scoreboard;
 
	seq_itm data;										// instance/handler for transaction class
									 
	uvm_analysis_imp #(seq_itm, scoreboard) aip;		// uvm_analysis_imp i.e circule and two argument								
	
	`uvm_component_utils(scoreboard)					// factory regstration

	function new(input string name = "scoreboard", uvm_component parent = null);	// component in UBCH hence two arguments	
		super.new(name,parent);
		aip = new("aip",this);							// object for aip
	endfunction: new

				
// build_phase:- responsible for building all lower level components
//		 executes in top down manner.	


	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		data = seq_itm::type_id::create("data");		// object for transaction
	endfunction: build_phase


// ap has write method which is non-blocking in nature i.e function


	virtual function void write(input seq_itm t);		// implementation details

		`uvm_info(get_type_name(),"data rcvd from Monitor ap",UVM_NONE)
		t.print();										// just print transctions

		if(t.y == t.a + t.b) 		

			`uvm_info(get_type_name(),"Test is passed",UVM_NONE)
		else
			`uvm_error(get_type_name(),"Test is Failed")	// error has by default verbosity is UVM_NONE
								
	endfunction: write


endclass: scoreboard

          
          
          
          
// ------------------- subscriber class ---------------------
          

// not manadatory to inherit from uvm_subscriber(we can extends from uvm_component), but its recommended practice           
          
//uvm_subscriber component class in UBCH, Encapsulates a uvm_analysis_export and associated virtual write method
          
// analysis export is for receiving transactions from a connected analysis export          
          
          


class addr_subscriber extends uvm_subscriber #(seq_itm);


  	seq_itm req;
  
	`uvm_component_utils(addr_subscriber)
  
	
 	
	
	covergroup cg;

      	option.per_instance = 1;		
      
		A : coverpoint req.a;					// implicit/auto bins
		B : coverpoint req.b;
		Y : coverpoint req.y;

	endgroup: cg
  
  
  
  	 function new(input string name = "addr_subscriber", uvm_component parent = null); 
		super.new(name, parent);
        req = seq_itm::type_id::create("req");
        cg = new();		
  	endfunction: new
  





	virtual function void write(input seq_itm t);

		`uvm_info(get_type_name(),"data rcvd from Monitor ap", UVM_NONE)
		t.print();							// just print transctions

		
		//a  = t.a;
		//b  = t.b;
		//y  = t.y;
      
      	req = t;							// data container req
		
      cg.sample();							// sample coverage whenever received an objects from ap

		`uvm_info(get_type_name(), $sformatf(" ---- cvg is %0f", cg.get_coverage()), UVM_NONE)  // %f -> real number in decimal format

		
	endfunction : write

	


endclass: addr_subscriber          
          
      


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// ----------------------  env class  ----------------------

// instances of sb, agent and coverage collector if any
// connect analysis port(ap) of monitor and analysis implimentation(aip) port of SB
// monitor is an initiator and SB is a target.




class env extends uvm_env;

  
  
	scoreboard 		sb;								// instances for all i.e SB,agent and virtual_sequencer
	agent			agt;
	addr_subscriber sbc;
	
  	
  	
  
	`uvm_component_utils(env)						// factory registration

	function new(input string name = "env", uvm_component parent = null);	// component hence two arguments	
		super.new(name,parent);
	endfunction: new 

  
  	
			
									
// build_phase:- responsible for building all lower level components
//		 executes in top down manner.

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sb = scoreboard::type_id::create("sb",this);		// creating all lower level components i.e sb, agent ,sbc
		agt = agent::type_id::create("agt",this);			// using factory's create method
      	sbc = addr_subscriber::type_id::create("sbc",this);
	endfunction: build_phase


// connect_phase:- responsible for establishing connection between all created component by TLM port-export
//		   executes in buttom up manner.

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agt.mon_h.ap.connect(sb.aip);				// connection ap of mon and aip of sb, start with mon bcz it's an initiator
        agt.mon_h.ap.connect(sbc.analysis_export);
	endfunction: connect_phase							
									

endclass: env




// ------------------- base_test class ----------------------


// creating an env and setting a configuration parameter



class base_test extends uvm_test;
	
	env 	  		env_h;								// instances/handler for env 
	agent_config	a_cfg;								// instances/handler for config class
  
  	

	`uvm_component_utils(base_test)						// factory registration

	function new(input string name = "base_test",uvm_component parent = null);	// component hence two arguments	
		super.new(name,parent);
	endfunction: new



// build_phase:- responsible for building all lower level components
//		 executes in top down manner.	

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env_h = env::type_id::create("env",this);					// creating an objects for env and generator(sequence)
		a_cfg = agent_config::type_id::create("a_cfg");
		uvm_config_db #(agent_config)::set(this,"*","agent_configuration",a_cfg);
	endfunction: build_phase


// end_of_elaboration_phase:- print_topology executes in buttom up manner.
//	       			

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();	
	endfunction: end_of_elaboration_phase


// report_phase:- display result of the simulation.
//		  executes in buttom up manner.


	virtual function void report_phase(uvm_phase phase);
		
		uvm_report_server svr;

		super.report_phase(phase);

		svr = uvm_report_server::get_server();

		if(svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin: B1

			`uvm_info(get_type_name(), "--------------------------------------", UVM_NONE)
			`uvm_info(get_type_name(), "-------------- TEST FAIL -------------", UVM_NONE)
			`uvm_info(get_type_name(), "--------------------------------------", UVM_NONE)

		end: B1
	
		else begin: B2

			`uvm_info(get_type_name(), "--------------------------------------", UVM_NONE)
			`uvm_info(get_type_name(), "-------------- TEST PASS -------------", UVM_NONE)
			`uvm_info(get_type_name(), "--------------------------------------", UVM_NONE)

		end: B2

	endfunction: report_phase


endclass: base_test



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// ------------------- test class ----------------------


// choose which specific sequence is to be send to driver through sequencer
// i.e starting particular sequence on the sequencer


class test_one extends base_test;

	
	sequence1 seq1;
  
  	 	// -------- for callback concept -------- 
  
  	driver 		  drv_h;										// instances for drv and callback classes
  	drv_callback1 cb;
		
	`uvm_component_utils(test_one)							// factory registration

	function new(input string name = "test_one", uvm_component parent = null);// component hence two arguments	
		super.new(name,parent);
      	drv_h = new("drv_h");
        cb = new("cb");
	endfunction: new

	
// build_phase:- responsible for building all lower level components
//		 executes in top down manner.	


	virtual function void build_phase(uvm_phase phase);		    // simply calling super.build_phase bcz parent 
        super.build_phase(phase);								// build_phase containing a logic corresponding to config_db and creating the env
      	uvm_callbacks #(driver, drv_callback)::add(drv_h, cb);
	endfunction: build_phase


// run_phase:- task bcz contain delay:- driver drive stimuls to DUT and monitor capture information from DUT based on DUT protocol.
//	       executes in parallel and all pre-post run phases.


	virtual task run_phase(uvm_phase phase);						
		seq1 = sequence1::type_id::create("seq1");			// type_id is a wrapper created by 
		phase.raise_objection(this);	 	
        seq1.start(env_h.agt.seqr_h);					    // start sequence on sequencer(seq_object.start(env.agt.seqr))
		phase.drop_objection(this);							// set a drain time for the env if desired
	endtask: run_phase	
endclass: test_one



// ------------------- top module ----------------------


module top_tb();
	adder_if vif();								// () is mandatory

	adder_rtl DUT(
			.a(vif.a),							// DUT instantiation
			.b(vif.b),
			.y(vif.y)
			);
  
 
	initial begin: B1							// :: bcz static method , set and get have 4 arguments
        uvm_config_db #(virtual adder_if)::set(null,"*","virtual_intf",vif);
        run_test("test_one");					// run_test is a method(taks) 
	end: B1										// WHICH initiates to executes the phases starting for build_phase to final_phase
					
  	initial begin: B2
      $dumpfile("dump.vcd");
      $dumpvars;
      
    end: B2
endmodule: top_tb