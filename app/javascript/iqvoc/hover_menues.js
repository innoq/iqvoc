const navbarToggler = document.querySelector('.navbar-toggler');
const isNavbarCollapsed = () => !!navbarToggler && getComputedStyle(navbarToggler).display !== 'none';

document.querySelectorAll('ul.navbar-nav li.dropdown').forEach((dropdown) => {
  const menu = dropdown.querySelector('.dropdown-menu');
  const navLink = dropdown.querySelector(':scope > .nav-link');
  let timer;

  const schedule = (fn) => {
    clearTimeout(timer);
    timer = setTimeout(fn, 100);
  };

  dropdown.addEventListener('mouseenter', () => schedule(() => {
    if (isNavbarCollapsed()) return;
    if (menu) menu.style.display = 'block';
    if (navLink) navLink.classList.add('hover');
  }));

  dropdown.addEventListener('mouseleave', () => schedule(() => {
    if (isNavbarCollapsed()) return;
    if (menu) menu.style.display = '';
    if (navLink) navLink.classList.remove('hover');
  }));
});
