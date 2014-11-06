(function($,undefined){
	var 
		def={
			stuckClass:'isStuck'			
		}
		,doc=$(document)

	$.fn.TMStickUp=function(opt){
		opt=$.extend(true,{},def,opt)

		$(this).each(function(){
			var $this=$(this)
				,posY//=$this.offset().top+$this.outerHeight()
				,isStuck=false
				,clone=$this.clone().appendTo($this.parent()).addClass(opt.stuckClass)
				,height//=$this.outerHeight()
				,stuckedHeight=clone.outerHeight()
				,opened//=$.cookie&&$.cookie('panel1')==='opened'
				,tmr

			$(window).resize(function(){
				clearTimeout(tmr)				
				clone.css({top:isStuck?0:-stuckedHeight,visibility:isStuck?'visible':'hidden'})
				tmr=setTimeout(function(){
					posY=$this.offset().top//+$this.outerHeight()				
					height=$this.outerHeight()
					stuckedHeight=clone.outerHeight()
					opened=$.cookie&&$.cookie('panel1')==='opened'

					clone.css({top:isStuck?0:-stuckedHeight})
				},40)
			}).resize()

			clone.css({
				position:'fixed'				
				,width:'100%'
			})

			$this
				.on('rePosition',function(e,d){
					if(isStuck)
						clone.animate({marginTop:d},{easing:'linear'})
					if(d===0)
						opened=false
					else
						opened=true
				})
			
			doc
				.on('scroll',function(){
					var scrollTop=doc.scrollTop()

					if(scrollTop>=posY&&!isStuck){						
						clone
							.stop()
							.css({visibility:'visible'})
							.animate({
								top:0
								,marginTop:opened?50:0
							},{

							})
							
						isStuck=true
					}
					
					if(scrollTop<posY+height&&isStuck){
						clone
							.stop()
							.animate({
								top:-stuckedHeight
								,marginTop:0
							},{
								duration:200
								,complete:function(){
									clone.css({visibility:'hidden'})
								}
							})
						
						isStuck=false
					}			
				})				
				.trigger('scroll')
		})
	}
})(jQuery)
