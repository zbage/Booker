class SplitPage

	def initialize content, size
		@pages = []
		page_index = 0
		@pages[0] = []
		i = 0
		content.each do |item|
			@pages[page_index] ||= []
			@pages[page_index] << item
			i = i + 1
			if i == size 
				page_index = page_index + 1
				i = 0
			end
		end
	end

	def total_page
		@pages.size
	end

	def get_page n
		raise "#{n} is out of bound!!!" if n - 1 > total_page 
		@pages[n - 1]
	end
end