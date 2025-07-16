/**
 * Projects Filter and Grid Management
 * Optimized for performance with debouncing and smooth animations
 */

class ProjectsFilter {
    constructor() {
        this.filterButtons = document.querySelectorAll('.filter-btn');
        this.projectCards = document.querySelectorAll('.project-card');
        this.bentoGrid = document.querySelector('.bento-grid');
        this.loadMoreBtn = document.getElementById('loadMoreBtn');
        
        // Cache DOM elements for better performance
        this.cardElements = Array.from(this.projectCards);
        
        this.init();
    }
    
    init() {
        this.bindFilterEvents();
        this.bindKeyboardNavigation();
        this.bindLoadMoreEvent();
        this.injectStyles();
    }
    
    /**
     * Debounce function to prevent excessive filtering
     */
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
    
    /**
     * Optimized filter function with smooth animations
     */
    filterProjects(filter) {
        // Add loading state
        this.bentoGrid.style.opacity = '0.7';
        this.bentoGrid.style.pointerEvents = 'none';
        
        // Use requestAnimationFrame for smooth animations
        requestAnimationFrame(() => {
            const visibleCards = [];
            
            this.cardElements.forEach((card, index) => {
                const cardCategory = card.getAttribute('data-category');
                const shouldShow = filter === 'all' || cardCategory === filter;
                
                if (shouldShow) {
                    visibleCards.push(card);
                    card.style.display = 'block';
                    card.style.opacity = '0';
                    card.style.transform = 'translateY(20px)';
                    
                    // Stagger animations for better visual effect
                    setTimeout(() => {
                        card.style.opacity = '1';
                        card.style.transform = 'translateY(0)';
                        card.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                    }, index * 50);
                } else {
                    card.style.opacity = '0';
                    card.style.transform = 'translateY(20px)';
                    card.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                    
                    setTimeout(() => {
                        card.style.display = 'none';
                    }, 300);
                }
            });
            
            // Update grid layout based on visible cards
            setTimeout(() => {
                this.bentoGrid.style.opacity = '1';
                this.bentoGrid.style.pointerEvents = 'auto';
                
                // Update counter if exists
                this.updateProjectsCounter(visibleCards.length);
                
                // Dispatch custom event for other components
                this.dispatchFilterEvent(filter, visibleCards.length);
            }, 500);
        });
    }
    
    /**
     * Update projects counter display
     */
    updateProjectsCounter(count) {
        const counter = document.querySelector('.projects-counter');
        if (counter) {
            counter.textContent = `${count} project${count !== 1 ? 's' : ''}`;
        }
    }
    
    /**
     * Dispatch custom event for filter changes
     */
    dispatchFilterEvent(filter, count) {
        const event = new CustomEvent('projectsFiltered', {
            detail: { filter, count }
        });
        document.dispatchEvent(event);
    }
    
    /**
     * Update active filter button
     */
    updateActiveButton(activeButton) {
        this.filterButtons.forEach(btn => {
            btn.classList.remove('active');
            btn.classList.add('bg-gray-200', 'text-gray-700');
            btn.classList.remove('bg-gray-900', 'text-white');
        });
        
        activeButton.classList.add('active');
        activeButton.classList.remove('bg-gray-200', 'text-gray-700');
        activeButton.classList.add('bg-gray-900', 'text-white');
    }
    
    /**
     * Bind filter button events
     */
    bindFilterEvents() {
        // Create debounced filter function
        const debouncedFilter = this.debounce(this.filterProjects.bind(this), 100);
        
        this.filterButtons.forEach(button => {
            button.addEventListener('click', (e) => {
                e.preventDefault();
                
                const filter = button.getAttribute('data-filter');
                
                // Update active button with smooth transition
                this.updateActiveButton(button);
                
                // Apply filter
                debouncedFilter(filter);
            });
        });
    }
    
    /**
     * Bind keyboard navigation
     */
    bindKeyboardNavigation() {
        document.addEventListener('keydown', (e) => {
            if (e.key >= '1' && e.key <= '9') {
                const buttonIndex = parseInt(e.key) - 1;
                const targetButton = this.filterButtons[buttonIndex];
                if (targetButton) {
                    targetButton.click();
                }
            }
        });
    }
    
    /**
     * Bind load more functionality
     */
    bindLoadMoreEvent() {
        if (this.loadMoreBtn) {
            this.loadMoreBtn.addEventListener('click', () => {
                this.loadMoreProjects();
            });
        }
    }
    
    /**
     * Load more projects functionality
     */
    loadMoreProjects() {
        // Add loading state
        this.loadMoreBtn.innerHTML = `
            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Loading...
        `;
        
        // Simulate loading (replace with actual AJAX call)
        setTimeout(() => {
            this.loadMoreBtn.innerHTML = `
                Load More Projects
                <svg class="ml-2 -mr-1 w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                </svg>
            `;
        }, 1000);
    }
    
    /**
     * Inject CSS styles for smooth transitions
     */
    injectStyles() {
        const style = document.createElement('style');
        style.textContent = `
            .project-card {
                transition: opacity 0.3s ease, transform 0.3s ease;
            }
            
            .filter-btn {
                transition: all 0.2s ease;
            }
            
            .bento-grid {
                transition: opacity 0.3s ease;
            }
            
            /* Responsive grid improvements */
            @media (max-width: 768px) {
                .bento-grid {
                    grid-template-columns: 1fr;
                    auto-rows: 250px;
                }
            }
            
            @media (min-width: 769px) and (max-width: 1024px) {
                .bento-grid {
                    grid-template-columns: repeat(2, 1fr);
                    auto-rows: 200px;
                }
            }
            
            /* Loading animation */
            .animate-spin {
                animation: spin 1s linear infinite;
            }
            
            @keyframes spin {
                from { transform: rotate(0deg); }
                to { transform: rotate(360deg); }
            }
        `;
        
        if (!document.head.querySelector('[data-projects-filter-styles]')) {
            style.setAttribute('data-projects-filter-styles', '');
            document.head.appendChild(style);
        }
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new ProjectsFilter();
});

// Export for potential use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ProjectsFilter;
}